//
//  APIConnector.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// A singleton instance of APIConnector has the main responsibility of communicating to the Tidepool service:
/// - Given a username and password, login.
/// - Can refresh connection.
/// - Provides online/offline status.
/// - Get/put user data of various types (cbg, carb, etc.)
class APIConnector {
    
    // non-nil when "loggedIn", nil when "loggedOut"
    var session: TPSession?
    
    // Base URL for API calls, set during initialization
    var baseUrlString: String? {
        didSet {
            if let urlStr = baseUrlString {
                self.baseUrl = URL(string: urlStr)!
            } else {
                self.baseUrl = nil
            }
        }
    }
    var baseUrl: URL?

    /// Reachability object, valid during lifetime of this APIConnector, and convenience function that uses this
    var reachability: Reachability?

    init() {
        LogInfo("")
        
        if let reachability = reachability {
            reachability.stopNotifier()
        }
        self.reachability = Reachability()
        
        // Register for ReachabilityChangedNotification to monitor reachability changes
        do {
            try reachability?.startNotifier()
        } catch {
            LogError("Unable to start notifier!")
        }
    }
    
    // MARK: - Constants
    
    private let kSessionTokenHeaderId = "X-Tidepool-Session-Token"
    private let kSessionTokenResponseId = "x-tidepool-session-token"
    
    // Dictionary of servers and their base URLs
    private func serverUrl(_ server: TidepoolServer) -> String {
        switch server {
        case .development: return "https://dev-api.tidepool.org"
        case .staging: return "https://stg-api.tidepool.org"
        case .integration: return "https://int-api.tidepool.org"
        case .production: return "https://api.tidepool.org"
        }
    }
    private let kDefaultServer: TidepoolServer = .staging

    private var user: TPUser?
    func loggedInUser() -> TPUser? {
        return self.session?.user
    }
    
    func isConnectedToNetwork() -> Bool {
        if let reachability = reachability {
            return reachability.isReachable
        } else {
            LogError("Reachability object not configured!")
            return true
        }
    }

    //
    // MARK: - Initialization
    //
    
    deinit {
        reachability?.stopNotifier()
    }
    
    /// Logs in the user and obtains the session token for the session (stored internally)
    func login(with username: String, password: String, server: TidepoolServer?, completion: @escaping (Result<TPSession, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Login failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        var loginServer: TidepoolServer = kDefaultServer
        if let server = server {
            loginServer = server
        }
        self.baseUrlString = serverUrl(loginServer)

        // force current session nil if not already nil!
        self.session = nil
        // Similar to email inputs in HTML5, trim the email (username) string of whitespace
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Set our endpoint for login
        let urlExtension = "/auth/login"
        
        // Create the authorization string (user:pass base-64 encoded)
        let base64LoginString = NSString(format: "%@:%@", trimmedUsername, password)
            .data(using: String.Encoding.utf8.rawValue)?
            .base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        // Set our headers with the login string
        let headers = ["Authorization" : "Basic " + base64LoginString!]
        
        // Send the request and deal with the response as JSON
        sendRequest("POST", urlExtension: urlExtension, contentType: .urlEncoded, headers:headers, requiresToken: false) {
            result -> Void in
            
            // did the call happen? Typical fail case here would be offline
            guard case .success(let sendRequestResponse) = result else {
                var failure: TidepoolKitError
                if case .failure(let error) = result {
                    LogError("Login post failed with error: \(error)!")
                    failure = error
                } else {
                    failure = .badLoginResponse(nil)
                }
                completion(Result.failure(failure))
                return
            }

            // did we get a positive http response? Look specifically for authorization error.
            guard (sendRequestResponse.isSuccess()) else {
                var failure: TidepoolKitError
                if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    let description = "Login post failed with http response code: \(statusCode)"
                    LogError(description)
                    if statusCode == 401 {
                        failure = .unauthorized
                    } else {
                        failure = .badLoginResponse("description")
                    }
                } else {
                    failure = .badLoginResponse(nil)
                }
                LogError("Login post failed!")
                completion(Result.failure(failure))
                return
            }
            
            // failures past this point should be rare, due to bad coding here or service is in a bad state...
            guard let httpResponse = sendRequestResponse.httpResponse else {
                let description = "Login response not a valid http response!"
                LogError(description)
                completion(Result.failure(.badLoginResponse(description)))
                return
            }
            
            guard let token = httpResponse.allHeaderFields[self.kSessionTokenResponseId] as? String else {
                let description = "Login response contained no token in header!"
                LogError(description)
                completion(Result.failure(.badLoginResponse(description)))
                return
            }
            LogInfo("Login returned token: \(token)")

            guard let data = sendRequestResponse.data else {
                let description = "Login returned token but no data!"
                LogError(description)
                completion(Result.failure(.badLoginResponse(description)))
                return
            }
            
            guard let serviceUser = TPUser.fromJsonData(data) else {
                let description = "Login json response not parseable as TPUser!"
                LogError(description)
                completion(Result.failure(.badLoginResponse(description)))
                return
            }
        
            self.session = TPSession(token, user: serviceUser, server: loginServer)
            LogInfo("Logged into \(loginServer.rawValue) server successfully! Returned userId = \(serviceUser.userId), userName: \(String(describing: serviceUser.userName))")
            NotificationCenter.default.post(name: TidepoolLogInChangedNotification, object:self)
            completion(Result.success(self.session!))
        }
    }
    
    func login(with session: TPSession) -> Result<TPSession, TidepoolKitError> {
        if self.session != nil {
            LogInfo("Login with existing TPSession failed: already logged in!")
            return Result.failure(.alreadyLoggedIn)
        }
        self.session = session
        self.baseUrlString = serverUrl(session.server)
        LogInfo("Logged in with existing TPSession!")
        NotificationCenter.default.post(name: TidepoolLogInChangedNotification, object:self)
        return Result.success(session)
    }
    
    func logout() {
        LogVerbose("")
        let wasLoggedIn = self.session != nil
        self.session = nil
        self.baseUrlString = nil
        // TODO: first sent logout message; make this async with optional completion!
        if wasLoggedIn {
            NotificationCenter.default.post(name: TidepoolLogInChangedNotification, object:self)
        }
    }

    //
    // MARK: - User api methods
    //
    
    /// Pass type.self to enable type inference in all cases.
    /// Optional userId, to fetch profiles for other users than logged in user.
    func fetch<T: TPFetchable>(_ type: T.Type, user: TPUser, parameters: [String: String]? = nil, headers: [String: String]? = nil, _ completion: @escaping (Result<T, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Operation failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        let urlExtension = T.urlExtension(forUser: user.userId)
        
        sendRequest("GET", urlExtension: urlExtension, parameters: parameters, headers: headers) {
            result -> Void in
            
            // did the call happen? Typical fail case here would be offline
            guard case .success(let sendRequestResponse) = result else {
                var failure: TidepoolKitError
                if case .failure(let error) = result {
                    LogError("Tidepool fetch failed with error: \(error)!")
                    failure = error
                } else {
                    failure = .serviceError(nil)
                }
                completion(Result.failure(failure))
                return
            }
 
            guard (sendRequestResponse.isSuccess()) else {
                var failure: TidepoolKitError
                if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    LogError("Tidepool fetch failed with http response code: \(statusCode)")
                    if statusCode == 401 {
                        failure = .unauthorized
                    } else if statusCode == 404 {
                        failure = .dataNotFound
                    } else {
                        failure = .serviceError(statusCode)
                    }
                } else {
                    failure = .serviceError(nil)
                }
                LogError("Tidepool fetch failed!")
                completion(Result.failure(failure))
                return
            }

            // failures past this point should be rare, due to bad coding here or service is in a bad state...
           guard let data = sendRequestResponse.data else {
                LogError("Tidepool fetch returned no data!")
                completion(Result.failure(.noDataInResponse))
                return
            }
            
            guard let tpObject = T.fromJsonData(data) as? T else {
                LogError("response not parseable as json dict!")
                completion(Result.failure(.badJsonInResponse))
                return
            }

            LogInfo("Tidepool fetch succeeded with object \(tpObject)")
            completion(Result.success(tpObject))

        }
    }
    
    /// Pass type.self to enable type inference in all cases.
    /// Optional userId, to fetch profiles for other users than logged in user.
    private func post<P: TPPostable, T: TPFetchable>(_ postable: P, _ fetchType: T.Type, headers: [String: String]? = nil, userId: String? = nil, _ completion: @escaping (Result<T, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Post failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        guard let sessionUser = self.session?.user else {
            LogError("Post failed, no user logged in!")
            completion(Result.failure(.notLoggedIn))
            return
        }

        let fetchForUserId = sessionUser.userId
        let urlExtension = P.urlExtension(forUser: fetchForUserId)
        
        guard let body = postable.postBodyData() else {
            LogError("Post failed, no data to post!")
            completion(Result.failure(.internalError))
            return
        }
        
        sendRequest("POST", urlExtension: urlExtension,  contentType: .json, headers: headers, body: body) {
            result -> Void in
            
            // did the call happen? Typical fail case here would be offline
            guard case .success(let sendRequestResponse) = result else {
                var failure: TidepoolKitError
                if case .failure(let error) = result {
                    LogError("Tidepool fetch failed with error: \(error)!")
                    failure = error
                } else {
                    failure = .serviceError(nil)
                }
                completion(Result.failure(failure))
                return
            }
            
            guard (sendRequestResponse.isSuccess()) else {
                var failure: TidepoolKitError
                if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    LogError("Tidepool post failed with http response code: \(statusCode)")
                    if statusCode == 401 {
                        failure = .unauthorized
                    } else {
                        failure = .serviceError(statusCode)
                    }
                } else {
                    failure = .serviceError(nil)
                }
                LogError("Tidepool post failed!")
                completion(Result.failure(failure))
                return
            }
            
            // failures past this point should be rare, due to bad coding here or service is in a bad state...
            guard let data = sendRequestResponse.data else {
                LogError("Tidepool post returned no data!")
                completion(Result.failure(.noDataInResponse))
                return
            }
            
            guard let tpObject = T.fromJsonData(data) as? T else {
                LogError("response not parseable as json dict!")
                completion(Result.failure(.badJsonInResponse))
                return
            }
            
            completion(Result.success(tpObject))
        }
    }

    /// Pass type.self to enable type inference in all cases.
    /// - parameter httpMethod: "POST" or "DELETE"
    func upload<T: TPUploadable>(_ uploadable: T, uploadId: String, httpMethod: String, _ completion: @escaping (Result<Bool, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Post failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        let urlExtension = "/v1/data_sets/" + uploadId + "/data"
        
        guard let body = uploadable.postBodyData() else {
            LogError("Post failed, no data to upload!")
            completion(Result.failure(.internalError))
            return
        }
        
        guard httpMethod == "POST" || httpMethod == "DELETE" else {
            LogError("Upload does not support \(httpMethod)!")
            completion(Result.failure(.internalError))
            return
        }
        
        sendRequest(httpMethod, urlExtension: urlExtension,  contentType: .json, body: body) {
            result -> Void in
            
            // did the call happen? Typical fail case here would be offline
            guard case .success(let sendRequestResponse) = result else {
                var failure: TidepoolKitError
                if case .failure(let error) = result {
                    LogError("Tidepool upload failed with error: \(error)!")
                    failure = error
                } else {
                    failure = .serviceError(nil)
                }
                completion(Result.failure(failure))
                return
            }
            
            guard (sendRequestResponse.isSuccess()) else {
                var failure: TidepoolKitError
                 if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    LogError("Tidepool upload failed with http response code: \(statusCode)")
                    failure = .serviceError(statusCode)
                    if statusCode == 401 {
                        failure = .unauthorized
                    } else if statusCode == 400 {
                        // Note: not all 400 errors are the result of samples that fail service validation.
                        // Note: the success at this level will be turned into an error at the calling level, this is just done here since the failure path doesn't carry data...
                        if let data = sendRequestResponse.data {
                            let badSamples = uploadable.parseErrResponse(data)
                            failure = .badRequest(badSamples)
                        }
                    }
                 } else {
                    failure = .serviceError(nil)
                }
                LogError("Tidepool upload failed!")
                completion(Result.failure(failure))
                return
            }
            
            completion(Result.success(true))
        }
    }

    //
    // MARK: - Private methods for upload support
    //
    
    /// Call this if currentUploadId is nil, before uploading data, after fetching user profile, to ensure we have a dataset id for data uploads (if so enabled)
    /// - parameter dataset: The service is queried to find an existing dataset that matches this; if no existing match is found, a new dataset will be created.
    /// - parameter completion: Method that will be called when this async operation has completed. If successful, the matching or new TPDataset is returned.
    func getDataset(for user: TPUser, matching configDataset: TPDataset,  _ completion: @escaping (Result<TPDataset, TidepoolKitError>) -> (Void)) {
        
        // TODO: should also verify that this is a DSAUser... i.e., has a profile in the user. Something we should fetch and persist, so the TPUser object includes a persisted isDSAUser field.
        
        // First try fetching one from the server that matches the one passed in...
        self.getDatasets(user: user) {
            result in
            switch result {
            case .success(let datasets):
                var matchingDS: TPDataset?
                for dataSet in datasets {
                    if dataSet.client == configDataset.client && dataSet.deduplicator == configDataset.deduplicator {
                        LogInfo("Found dataset matching configDataset (\(configDataset))")
                        matchingDS = dataSet
                        break
                    }
                }
                if let matchingDS = matchingDS {
                    LogInfo("configureUploadId fetch succeeded: \(matchingDS)")
                    completion(.success(matchingDS))
                    return
                }
                // no match found, fall through and create one...
            case .failure(let error):
                LogError("configureUploadId fetchDataset failed! Error: \(error)")
                // network failure for fetchDataset, don't try creating a new one in case one already does exist, unless it was a 404 data not found case...
                guard case .dataNotFound = error else {
                    completion(.failure(error))
                    return
                }
            }

            // No matching existing dataset found, try creating a new one...
            LogInfo("Dataset for current client/version not found, try creating new dataset!")
            self.createDataset(configDataset) {
                result in
                completion(result)
            }
        }
    }
    
    /// Ask service for the existing mobile app upload id for this client and version, if one exists.
    /// - parameter completion: Method that accepts a Result. Failure code is returned if network fetch of dataset array fails, otherwise success is returned. The success value will be an array of zero or more TPDataset objects.
    internal func getDatasets(user: TPUser, _ completion: @escaping (Result<[TPDataset], TidepoolKitError>) -> (Void)) {
        LogInfo("Try fetching existing dataset!")
        
        self.fetch(APIDataSetArray.self, user: user) {
            result in
            switch result {
            case .success(let apiDataSetArray):
                LogInfo("APIDataSetArray fetch succeeded: \n\(apiDataSetArray)")
                completion(.success(apiDataSetArray.datasetArray))
            case .failure(let error):
                LogError("APIDataSetArray fetch failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    /// Ask service to create a new upload id. Should only be called after fetchDataSet returns a nil array (no existing upload id).
    /// - parameter completion: Method that accepts an optional APIDataSet if the create succeeds, and an error result if not.
    private func createDataset(_ configDataset: TPDataset, _ completion: @escaping (Result<TPDataset, TidepoolKitError>) -> (Void)) {
        LogInfo("Try creating a new dataset!")
        
        self.post(configDataset, TPDataset.self) {
            result in
            switch result {
            case .success(let apiDataSet):
                NSLog("createDataset post succeeded: \n\(apiDataSet)")
                completion(.success(apiDataSet))
            case .failure(let error):
                NSLog("createDataset post failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }


    //
    // MARK: - Lower-level networking methods
    //
    
    class SendRequestResponse {
        let request: URLRequest?
        var response: URLResponse?
        var data: Data?
        var error: NSError?
        var httpResponse: HTTPURLResponse? {
            return response as? HTTPURLResponse
        }
        init(
            request: URLRequest? = nil,
            response: HTTPURLResponse? = nil,
            data: Data? = nil,
            error: NSError? = nil)
        {
            self.request = request
            self.response = response
            self.data = data
            self.error = error
        }
        
        func isSuccess() -> Bool {
            if let status = httpResponse?.statusCode {
                if status == 200 || status == 201 {
                    return true
                }
            }
            return false
        }
    }
    
    enum ContentType {
        case json
        case urlEncoded
    }
    
    func sendRequest(_ method: String, urlExtension: String, contentType: ContentType? = nil, parameters: [String: String]? = nil, headers: [String: String]? = nil, requiresToken: Bool = true, body: Data? = nil, completion: @escaping (Result<SendRequestResponse, TidepoolKitError>) -> Void) {
        
        guard isConnectedToNetwork() else {
            LogError("Not connected to network")
            completion(Result.failure(.offline))
            return
        }
        
        var urlString = baseUrlString! + urlExtension
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

        var queryParameters: [URLQueryItem] = []
        if let parameters = parameters {
            for (key, value) in parameters {
                let item = URLQueryItem(name: key, value: value)
                queryParameters.append(item)
            }
        }

        var urlComps = URLComponents(string: urlString)!
        urlComps.queryItems = queryParameters
        let url = urlComps.url!
        LogVerbose("url: \(url)")

        var request = URLRequest(url: url)
        let sendResponse = SendRequestResponse(request: request)
        request.httpMethod = method
        
        if let contentType = contentType {
            let contentTypeStr = contentType == .json ? "application/json" : "application/x-www-form-urlencoded; charset=utf-8"
            request.setValue(contentTypeStr, forHTTPHeaderField: "Content-Type")
        }
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
                LogInfo("set http header: \(key) to: \(value)")
            }
        }
        
        if requiresToken {
            guard let token = self.session?.authenticationToken else {
                LogError("user not logged in!")
                completion(Result.failure(.notLoggedIn))
                return
            }
            request.setValue("\(token)", forHTTPHeaderField: kSessionTokenHeaderId)
        }
        
        request.httpBody = body
        
        if let body = body {
            if let dataStr = String(data: body, encoding: .ascii) {
                LogVerbose("body as ascii: \(dataStr)")
            }
        }
        
        request.setValue(self.userAgentString(), forHTTPHeaderField: "User-Agent")
        
        if let urlStr = request.url?.absoluteString {
            LogVerbose("sendRequest \(method) url: \(urlStr)")
        }

        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            DispatchQueue.main.async(execute: {
                sendResponse.response = response
                sendResponse.data = data
  
                if let urlStr = request.url?.absoluteString {
                    LogVerbose("sendRequest \(method) url: \(urlStr)")
                }

                if let data = data {
                    if let dataStr = String(data: data, encoding: .ascii) {
                        LogVerbose("response as ascii: \(dataStr)")
                    }
                }
                
                sendResponse.error = error as NSError?
                completion(Result.success(sendResponse))
            })
            return
        }
        LogVerbose("task.resume...")
        task.resume()
    }
    
    // User-agent string, based on that from Alamofire, but common regardless of whether Alamofire library is used
    private func userAgentString() -> String {
        if _userAgentString == nil {
            _userAgentString = {
                if let info = Bundle.main.infoDictionary {
                    let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
                    let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
                    let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
                    let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
                    let osNameVersion: String = {
                        let version = ProcessInfo.processInfo.operatingSystemVersion
                        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
                        let osName: String = {
                            #if os(iOS)
                            return "iOS"
                            #elseif os(watchOS)
                            return "watchOS"
                            #elseif os(tvOS)
                            return "tvOS"
                            #elseif os(macOS)
                            return "OS X"
                            #elseif os(Linux)
                            return "Linux"
                            #else
                            return "Unknown"
                            #endif
                        }()
                        return "\(osName) \(versionString)"
                    }()
                    return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); \(osNameVersion))"
                }
                return "TidepoolKit"
            }()
        }
        return _userAgentString!
    }
    private var _userAgentString: String?
    
 }
