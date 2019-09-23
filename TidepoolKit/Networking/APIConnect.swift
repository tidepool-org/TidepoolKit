//
//  APIConnector.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

typealias NetworkRequestCompletionHandler = (Data?, URLResponse?, Error?) -> Void
protocol TidepoolNetworkInterface {
    func sendStandardRequest(_ request: URLRequest, completion: @escaping NetworkRequestCompletionHandler)
    func sendBackgroundRequest(_ request: URLRequest, body: Data, completion: @escaping NetworkRequestCompletionHandler)
}

public protocol ReachabilitySource {
    func serviceIsReachable() -> Bool
    func configureNotifier(_ on: Bool) -> Bool
}

extension Reachability: ReachabilitySource {
    public func serviceIsReachable() -> Bool {
        return self.isReachable
    }
    public func configureNotifier(_ on: Bool) -> Bool {
        if on {
            do {
                try self.startNotifier()
                return true
            } catch {
                return false
            }
        } else {
            self.stopNotifier()
            return true
        }
    }
}

/// A singleton instance of APIConnector has the main responsibility of communicating to the Tidepool service:
/// - Given a username and password, login.
/// - Can refresh connection.
/// - Provides online/offline status.
/// - Get/put user data of various types (cbg, carb, etc.)
class APIConnector {
    
    // non-nil when "loggedIn", nil when "loggedOut"
    var session: TPSession?
    var apiQueue: DispatchQueue
    
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
    var reachability: ReachabilitySource?
    var networkRequestHandler: TidepoolNetworkInterface
    
    init(queue: DispatchQueue) {
        LogInfo("")
        self.apiQueue = queue
        self.networkRequestHandler = NetworkRequestHandler(queue)
        self.configureReachability()
    }
    
    func configureReachability(_ reachability: ReachabilitySource? = nil) {
        _ = self.reachability?.configureNotifier(false)
        self.reachability = reachability
        if self.reachability == nil {
            guard let defaultReachability = Reachability() else {
                LogError("Unable to create reachability object!")
                return
            }
            self.reachability = defaultReachability
            // Register for ReachabilityChangedNotification to monitor reachability changes
            if !defaultReachability.configureNotifier(true) {
                LogError("Unable to start reachability notifier!")
            }
        }
    }
    
    // TODO: if replacing a current NetworkRequestHandler, might want to cancel any outstanding requests!
    func configureNetworkInterface(_ networkInterface: TidepoolNetworkInterface? = nil) {
        if let networkInterface = networkInterface {
            self.networkRequestHandler = networkInterface
        } else {
            self.networkRequestHandler = NetworkRequestHandler(apiQueue)
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
            return reachability.serviceIsReachable()
        } else {
            LogError("Reachability object not configured!")
            return true
        }
    }

    //
    // MARK: - Initialization
    //
    
    deinit {
        _ = reachability?.configureNotifier(false)
    }
    
    /// Logs in the user and obtains the session token for the session (stored internally)
    func login(with username: String, password: String, server: TidepoolServer?, completion: @escaping (Result<TPSession, TidepoolKitError>) -> (Void)) {
        
        if let error = isOfflineError() {
            completion(Result.failure(error))
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
            sendResponse, error in
            
            guard error == nil else {
                let error = error!
                LogError("Login post failed with error: \(error)!")
                completion(Result.failure(error))
                return
            }
            
            // failures past this point should be rare, due to bad coding here or service is in a bad state...
            guard let httpResponse = sendResponse.httpResponse else {
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

            guard let data = sendResponse.data else {
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
            LogInfo("Logged into \(loginServer.rawValue) server successfully! Returned userId = \(serviceUser.userId), userName: \(String(describing: serviceUser.userEmail))")
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
    
    func clearSession() {
        LogVerbose("")
        let wasLoggedIn = self.session != nil
        self.session = nil
        self.baseUrlString = nil
        // only send notification if we were logged in...
        if wasLoggedIn {
            NotificationCenter.default.post(name: TidepoolLogInChangedNotification, object:self)
        }
    }
    
    func refreshToken(_ completion: @escaping (_ result: Result<TPSession, TidepoolKitError>) -> (Void)) {
        
        let error = isOfflineOrUnauthorizedError()
        guard error == nil else {
            completion(Result.failure(error!))
            return
        }
        
        guard let loginServer = self.session?.server else {
            completion(Result.failure(.internalError))
            return
        }
        
        // Set our endpoint for token refresh (same as login)
        let urlExtension = "/auth/login"
        sendRequest("GET", urlExtension: urlExtension, contentType: .urlEncoded) {
            sendResponse, error in
            
            guard error == nil else {
                let error = error!
                LogError("Refresh failed, with error: \(error)!")
                // Note: sendRequest will clear the session on .unauthorized errors!
                completion(Result.failure(error))
                return
            }
            
            guard let httpResponse = sendResponse.httpResponse else {
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

            // Refresh the login user as well (email may have changed)
            let urlExtension = "/auth/user"
            self.sendRequest("GET", urlExtension: urlExtension, contentType: .urlEncoded) {
                sendResponse, error in
                
                guard error == nil else {
                    let error = error!
                    LogError("Login user refresh failed, with error: \(error)!")
                    // Note: the session will remain valid assuming error was not 401
                    completion(Result.failure(error))
                    return
                }
                
                guard let data = sendResponse.data else {
                    let description = "Login user refresh returned no data!"
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
                LogInfo("Refreshed session and login user successfully! Returned userId = \(serviceUser.userId), userEmail: \(String(describing: serviceUser.userEmail))")
                completion(Result.success(self.session!))
            }
        }
     }
    
    func logout(_ completion: @escaping (Result<Bool, TidepoolKitError>) -> (Void)) {
   
        guard self.session?.authenticationToken != nil else {
            LogInfo("Logout skipped, already logged out!")
            completion(Result.success(true))
            return
       }
        
        if let error = isOfflineError() {
            // still clear the session if offline.
            clearSession()
            completion(Result.failure(error))
            return
        }

        // Set our endpoint for logout
        let urlExtension = "/auth/logout"

        sendRequest("POST", urlExtension: urlExtension, contentType: .urlEncoded) {
            sendResponse, error in
            
            guard error == nil else {
                let error = error!
                LogError("Tidepool fetch failed with error: \(error)!")
                completion(Result.failure(error))
                return
            }
            
            completion(Result.success(true))
        }
        
        // clear retained session, so we always enter logged out state immediately, and send TidepoolLogInChangedNotification...
        clearSession()
    }

    //
    // MARK: - User api methods
    //
    
    /// Pass type.self to enable type inference in all cases.
    /// Optional userId, to fetch profiles for other users than logged in user.
    func fetch<T: TPFetchable>(_ type: T.Type, user: TPUser, parameters: [String: String]? = nil, headers: [String: String]? = nil, _ completion: @escaping (Result<T, TidepoolKitError>) -> (Void)) {
        
        let error = isOfflineOrUnauthorizedError()
        guard error == nil else {
            completion(Result.failure(error!))
            return
        }

        let urlExtension = T.urlExtension(forUser: user.userId)
        
        sendRequest("GET", urlExtension: urlExtension, parameters: parameters, headers: headers) {
            sendResponse, error in
            
            guard error == nil else {
                let error = error!
                LogError("Tidepool fetch failed with error: \(error)!")
                completion(Result.failure(error))
                return
            }

            // failures past this point should be rare, due to bad coding here or service is in a bad state...
           guard let data = sendResponse.data else {
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
        
        let error = isOfflineOrUnauthorizedError()
        guard error == nil else {
            completion(Result.failure(error!))
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
            sendResponse, error in
            
            guard error == nil else {
                let error = error!
                LogError("Tidepool post failed with error: \(error)!")
                completion(Result.failure(error))
                return
            }
            
            // failures past this point should be rare, due to bad coding here or service is in a bad state...
            guard let data = sendResponse.data else {
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
        
        let error = isOfflineOrUnauthorizedError()
        guard error == nil else {
            completion(Result.failure(error!))
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
        
        sendBackgroundRequest(httpMethod, urlExtension: urlExtension, body: body) {
            sendResponse, error in
            
            guard error == nil else {
                let error = error!
                LogError("Tidepool upload failed with error: \(error)!")
                var adjustedError = error
                if let statusCode = sendResponse.statusCode, statusCode == 400 {
                    if let data = sendResponse.data {
                        let badSamples = uploadable.parseErrResponse(data)
                        adjustedError = .badRequest(badSamples, response: data)
                    }
                }
                completion(Result.failure(adjustedError))
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
    
    private func isOfflineError() -> TidepoolKitError? {
        guard isConnectedToNetwork() else {
            LogError("network offline!")
            return .offline
        }
        return nil
    }
    
    private func isOfflineOrUnauthorizedError() -> TidepoolKitError? {
        if let error = isOfflineError() {
            return error
        }
        guard self.session?.authenticationToken != nil else {
            return .notLoggedIn
        }
        return nil
    }
    
    enum ContentType {
        case json
        case urlEncoded
    }
    
    /// Non-public struct used to consolidate URLRequest response data
    internal struct SendRequestResponse {
        let request: URLRequest?
        var response: URLResponse?
        var data: Data?
        var error: NSError?
        var httpResponse: HTTPURLResponse? {
            return response as? HTTPURLResponse
        }
        var statusCode: Int? {
            if let status = httpResponse?.statusCode {
                return status
            }
            return nil
        }
        
        init(
            request: URLRequest? = nil,
            response: URLResponse? = nil,
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

    typealias SendRequestCompletionHandler = (SendRequestResponse, TidepoolKitError?) -> Void

    // Assumes onLine, and authorized (unless requiresToken = false is passed). Call isOfflineOrUnauthorizedError() to check before calling this method!
    private func sendRequest(_ method: String, urlExtension: String, contentType: ContentType? = nil, parameters: [String: String]? = nil, headers: [String: String]? = nil, requiresToken: Bool = true, body: Data? = nil, completion: @escaping SendRequestCompletionHandler) {
        
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
                // should not get this if caller already checked!!! Send an empty response back...
                LogError("user not logged in!")
                completion(SendRequestResponse(), .notLoggedIn)
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

        self.networkRequestHandler.sendStandardRequest(request) {
            data, response, error in
            self.dispatchSendRequestResponse(request: request, data: data, response: response, error: error, completion: completion)
        }
    }
    
    // Used to dispatch all network request completions
    internal func dispatchSendRequestResponse(request: URLRequest, data: Data?, response: URLResponse?, error: Error?, completion: @escaping SendRequestCompletionHandler) {
        let sendResponse = SendRequestResponse(request: request, response: response, data: data, error: error as NSError?)
        
        if let urlStr = request.url?.absoluteString {
            LogVerbose("sendRequest completed: \(urlStr)")
        }
        
        if let data = data {
            if let dataStr = String(data: data, encoding: .ascii) {
                LogVerbose("response as ascii: \(dataStr)")
            }
        }
        
        var errorResult: TidepoolKitError? = nil
        let statusCode = sendResponse.statusCode
        if !sendResponse.isSuccess() {
            errorResult = .serviceError(nil)
            if let statusCode = statusCode {
                if statusCode == 401 {
                    errorResult = .unauthorized
                    // Clear our session here. This will change subsequent errors to .notLoggedIn, and the app will not make network requests!
                    self.clearSession()
                } else if statusCode == 404 {
                    errorResult = .dataNotFound
                } else {
                    errorResult = .serviceError(statusCode)
                }
            }
        }
        completion(sendResponse, errorResult)
    }
    
    //
    // MARK: - Background upload support
    //
    
    /*
     Current design follows that of the HealthKit uploaded used by Tidepool Mobile. A background URLSession is created here and used for upload requests. Data is pushed into a file to minimize use of RAM, though this may be an anachronism. Since shared data structures are used to track the request, calls are assumed to be synchronized.
     
    For testing purposes, it may be useful to pass in a different TidepoolNetworkInterface-conforming object to use. This can short-circuit the call to the service, and be used to inject errors or different data for test purposes.
    */
    
    // Assumes onLine, and authorized. Call isOfflineOrUnauthorizedError() to check before calling this method!
    private func sendBackgroundRequest(_ method: String, urlExtension: String, body: Data, completion: @escaping SendRequestCompletionHandler) {
        
        let urlString = baseUrlString! + urlExtension
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        let contentTypeStr = "application/json"
        request.setValue(contentTypeStr, forHTTPHeaderField: "Content-Type")
        
        guard let token = self.session?.authenticationToken else {
            // send an empty response back...
            LogError("user not logged in!")
            completion(SendRequestResponse(), .notLoggedIn)
            return
        }
        request.setValue("\(token)", forHTTPHeaderField: kSessionTokenHeaderId)
        request.setValue(self.userAgentString(), forHTTPHeaderField: "User-Agent")
        self.networkRequestHandler.sendBackgroundRequest(request, body: body) {
            (data, response, error) -> Void in
            self.dispatchSendRequestResponse(request: request, data: data, response: response, error: error, completion: completion)
        }
    }
    
    //
    // MARK: - Misc
    //
    
    // TODO: remove? Provide external api for setting user agent string?
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

// Helper class that encapsulates the code needed to perform background URLSession uploads.
class NetworkRequestHandler: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate, TidepoolNetworkInterface {
    
    let completionQueue: DispatchQueue
    
    init(_ completionQueue: DispatchQueue) {
        self.completionQueue = completionQueue
        super.init()
        _ = self.backgroundURLSession()
    }
    
    func sendStandardRequest(_ request: URLRequest, completion: @escaping NetworkRequestCompletionHandler) {

        let task = defaultURLSession().dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            self.completionQueue.async {
                completion(data, response, error)
            }
        }
        LogVerbose("task.resume...")
        task.resume()
    }
    
    func sendBackgroundRequest(_ request: URLRequest, body: Data, completion: @escaping NetworkRequestCompletionHandler) {
        // create a unique descriptor for this upload, and use it to identify the task as well as file we use to upload...
        let uploadDescriptor = self.nextUploadDescriptor()
        guard let fileUrl = savePostBodyForUpload(sampleData: body, identifier: uploadDescriptor) else {
            LogError("unable to save data to file!")
            completion(nil, nil, TidepoolKitError.internalError)
            return
        }
        // save the request info for when task completes...
        let requestInfo = TPRequestInfo(completion: completion, responseData: nil)
        self.requestsInProgress[uploadDescriptor] = requestInfo
        
        let uploadSession = backgroundURLSession()
        let uploadTask = uploadSession.uploadTask(with: request, fromFile: fileUrl)
        uploadTask.taskDescription = uploadDescriptor
        LogInfo("((self.mode.rawValue)) Created upload task: \(uploadTask.taskIdentifier)")
        uploadTask.resume()
    }
    
    // TODO: investigate use of cache file space for this; if the file disappears before the upload, the upload will fail, but how can this case be tested? Is it still necessary to save data to a file for background upload?
    private func savePostBodyForUpload(sampleData: Data, identifier: String) -> URL? {
        LogVerbose("identifier: \(identifier)")
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let postBodyURL = cachesDirectory.appendingPathComponent(identifier)
        do {
            try sampleData.write(to: postBodyURL, options: .atomic)
        } catch {
            return nil
        }
        return postBodyURL
    }

    private struct TPRequestInfo {
        var completion: NetworkRequestCompletionHandler
        var responseData: Data? = nil
    }
    
    private var requestsInProgress: [String: TPRequestInfo] = [:]
    private func nextUploadDescriptor() -> String {
        let result = "\(uploadCounter)"
        uploadCounter += 1
        return result
    }
    private var uploadCounter = 0

    // Currently unused... this would be needed to implement a public api for cancel
    private func cancelTasks() {
        LogVerbose("")
        if let session = self.uploadSession {
            session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) -> Void in
                LogInfo("Canceling \(uploadTasks.count) tasks")
                for uploadTask in uploadTasks {
                    LogInfo("Canceling task: \(uploadTask.taskIdentifier)")
                    uploadTask.cancel()
                }
            }
        }
    }
    
    //
    // MARK: - URLSessionDataDelegate
    //
    
    // Retain last upload response data for error messaging...
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        completionQueue.async {
            guard let uploadDescriptor = dataTask.taskDescription else {
                LogError("Upload task with no descriptor completed!")
                return
            }
            LogVerbose("saving data returned by upload task: \(uploadDescriptor)")
            // update the requestInfo with the response data
            if var requestInfo = self.requestsInProgress[uploadDescriptor] {
                requestInfo.responseData = data
                self.requestsInProgress[uploadDescriptor] = requestInfo
            }
        }
    }
    
    //
    // MARK: - URLSessionTaskDelegate
    //
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        completionQueue.async {
            guard let uploadDescriptor = task.taskDescription else {
                LogError("Upload task with no descriptor completed!")
                return
            }
            LogVerbose("upload task ended: \(uploadDescriptor)")
            
            guard let requestInfo = self.requestsInProgress[uploadDescriptor] else {
                LogError("Upload task '\(uploadDescriptor)' has no matching request!")
                return
            }
            
            let completion = requestInfo.completion
            let data = requestInfo.responseData
            self.requestsInProgress[uploadDescriptor] = nil
            
            let response = task.response as? HTTPURLResponse // may be nil
            completion(data, response, error)
        }
    }
    
    //
    // MARK: - URLSessionDelegate
    //
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        completionQueue.async {
            LogInfo("Upload session became invalid!")
            self.uploadSession = nil
            _ = self.backgroundURLSession()
        }
    }

    //
    // MARK: - methods to create URLSession's
    //
    
    func defaultURLSession() -> URLSession {
        return .shared
    }
    
    func backgroundURLSession() -> URLSession {
        LogVerbose("")
 
        if let uploadSession = self.uploadSession {
            return uploadSession
        }
        
        if !requestsInProgress.isEmpty {
            LogError("requestsInProgress dictionary is not empty while session is nil!")
            requestsInProgress = [:]
        }

        let configuration = URLSessionConfiguration.background(withIdentifier: self.backgroundUploadSessionIdentifier)
        configuration.timeoutIntervalForResource = 60 // 60 seconds
        let newUploadSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        newUploadSession.delegateQueue.maxConcurrentOperationCount = 1 // keep it simple...
        self.uploadSession = newUploadSession
        LogVerbose("Created upload session...")
        return newUploadSession
    }
    
    func invalidateBackgroundSession() {
        self.uploadSession = nil
    }
    
    private var uploadSession: URLSession?
    private let backgroundUploadSessionIdentifier = "UploadSessionId"

}
