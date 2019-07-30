/*
 * Copyright (c) 2019, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */

import Foundation

/// A singleton instance of APIConnector has the main responsibility of communicating to the Tidepool service:
/// - Given a username and password, login.
/// - Can refresh connection.
/// - Provides online/offline status.
/// - Get/put user data of various types (cbg, carb, etc.)
class APIConnector {
    
    // Session token, acquired on login and saved in NSUserDefaults
    var sessionTokenSetting: TPKitSetting
    var loggedInUserIdSetting: TPKitSetting
    var loggedInUserNameSetting: TPKitSetting
    
    // Exposed for testing only...
    var currentServiceSetting: TPKitSetting
    var currentUploadId: TPKitSetting

    // Base URL for API calls, set during initialization
    var baseUrl: URL?
    var baseUrlString: String?

    /// Reachability object, valid during lifetime of this APIConnector, and convenience function that uses this
    var reachability: Reachability?

    init(settings: TPKitSetting.Type) {
        self.sessionTokenSetting = settings.init(forKey: "SToken")
        self.loggedInUserIdSetting = settings.init(forKey: "LoggedInUserId")
        self.loggedInUserNameSetting = settings.init(forKey: "LoggedInUserName")
        self.currentServiceSetting = settings.init(forKey: "SCurrentService")
        self.currentUploadId = settings.init(forKey: "CurrentUploadId")
        self.baseUrlString = kServers[currentService]!
        self.baseUrl = URL(string: baseUrlString!)!
        LogInfo("Using service: \(self.baseUrl!)")
        
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
    private let kServers = [
        "Development" :  "https://dev-api.tidepool.org",
        "Staging" :      "https://stg-api.tidepool.org",
        "Integration" :  "https://int-api.tidepool.org",
        "Production" :   "https://api.tidepool.org"
    ]
    let kSortedServerNames = [
        "Development",
        "Staging",
        "Integration",
        "Production"
    ]
    private let kDefaultServerName = "Staging"

    private var user: TPUser?
    func loggedInUser() -> TPUser? {
        let token = self.sessionTokenSetting.value
        guard token != nil, let userId = self.loggedInUserIdSetting.value else {
            return nil
        }
        if self.user == nil {
            self.user = TPUser(userId, userName: self.loggedInUserNameSetting.value)
        }
        return self.user
    }
    
    /// Returns kDefaultServerName if setting is nil or not supported
    var currentService: String {
        set(newService) {
            currentServiceSetting.value = newService
        }
        get {
            let service = currentServiceSetting.value
            if service == nil || kServers[service!] == nil {
                return kDefaultServerName
            }
            return service!
        }
    }
    
    func isConnectedToNetwork() -> Bool {
        if let reachability = reachability {
            return reachability.isReachable
        } else {
            LogError("Reachability object not configured!")
            return true
        }
    }

    func serviceAvailable() -> Bool {
        if !isConnectedToNetwork() || sessionTokenSetting.value == nil {
            return false
        }
        return true
    }

    //
    // MARK: - Initialization
    //
    
    deinit {
        reachability?.stopNotifier()
    }
    
    func switchToServer(_ serverName: String) {
        LogVerbose("\(#function): \(serverName)")
        if (currentService != serverName) {
            currentService = serverName
            // clear out login settings...
            self.logout()
            // refresh connector since there is a new service...
            self.baseUrlString = kServers[currentService]!
            self.baseUrl = URL(string: baseUrlString!)!
            LogInfo("Switched to using service: \(self.baseUrlString!)")
            
            let notification = Notification(name: Notification.Name(rawValue: "switchedToNewServer"), object: nil)
            NotificationCenter.default.post(notification)
        }
    }
    
    /// Logs in the user and obtains the session token for the session (stored internally)
    func login(_ username: String, password: String, completion: @escaping (Result<TPUser, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Login failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        // force sessionToken nil if not already nil!
        self.sessionTokenSetting.value = nil
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
                var failure = TidepoolKitError.badLoginResponse
                if case .failure(let error) = result {
                    LogError("Login post failed with error: \(error)!")
                    failure = error
                }
                completion(Result.failure(failure))
                return
            }

            // did we get a positive http response? Look specifically for authorization error.
            guard (sendRequestResponse.isSuccess()) else {
                var failure = TidepoolKitError.badLoginResponse
                if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    LogError("Login post failed with http response code: \(statusCode)")
                    if statusCode == 401 {
                        failure = .unauthorized
                    }
                }
                LogError("Login post failed!")
                completion(Result.failure(failure))
                return
            }
            
            // failures past this point should be rare, due to bad coding here or service is in a bad state...
            guard let httpResponse = sendRequestResponse.httpResponse else {
                LogError("Login response not a valid http response!")
                completion(Result.failure(.badLoginResponse))
                return
            }
            
            guard let token = httpResponse.allHeaderFields[self.kSessionTokenResponseId] as? String else {
                LogError("Login response contained no token in header!")
                completion(Result.failure(.badLoginResponse))
                return
            }
            LogInfo("Login returned token: \(token)")

            guard let data = sendRequestResponse.data else {
                LogError("Login returned token but no data!")
                completion(Result.failure(.badLoginResponse))
                return
            }
            
            guard let serviceUser = APIUser.fromJsonData(data) else {
                LogError("Login response not parseable as json user!")
                completion(Result.failure(.badLoginResponse))
                return
            }
        
            LogInfo("Login success! Returned userId = \(serviceUser.userId), userName: \(String(describing: serviceUser.userName))")
            self.sessionTokenSetting.value = token
            self.loggedInUserIdSetting.value = serviceUser.userId
            self.loggedInUserNameSetting.value = serviceUser.userName
            self.user = TPUser(serviceUser)
            NotificationCenter.default.post(name: TidepoolLogInChangedNotification, object:self)
            completion(Result.success(self.user!))
        }
    }
    
    func logout() {
        LogVerbose("\(#function)")
        let wasLoggedIn = self.sessionTokenSetting.value != nil
        // Clear our session token and user settings
        self.sessionTokenSetting.value = nil
        self.loggedInUserIdSetting.value = nil
        self.loggedInUserNameSetting.value = nil
        self.currentUploadId.value = nil
        self.user = nil
        if wasLoggedIn {
            NotificationCenter.default.post(name: TidepoolLogInChangedNotification, object:self)
        }
    }

    //
    // MARK: - User api methods
    //
    
    /// Pass type.self to enable type inference in all cases.
    /// Optional userId, to fetch profiles for other users than logged in user.
    func fetch<T: TPFetchable>(_ type: T.Type, parameters: [String: String]? = nil, headers: [String: String]? = nil, userId: String? = nil, _ completion: @escaping (Result<T, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Operation failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        var fetchForUserId = userId
        if userId == nil {
            guard let user = self.loggedInUser() else {
                LogError("Operation failed, no user logged in!")
                completion(Result.failure(.notLoggedIn))
                return
            }
            fetchForUserId = user.userId
        }
        let urlExtension = T.urlExtension(forUser: fetchForUserId!)
        
        sendRequest("GET", urlExtension: urlExtension, parameters: parameters, headers: headers) {
            result -> Void in
            
            // did the call happen? Typical fail case here would be offline
            guard case .success(let sendRequestResponse) = result else {
                var failure = TidepoolKitError.serviceError
                if case .failure(let error) = result {
                    LogError("Tidepool fetch failed with error: \(error)!")
                    failure = error
                }
                completion(Result.failure(failure))
                return
            }
 
            guard (sendRequestResponse.isSuccess()) else {
                var failure = TidepoolKitError.serviceError
                if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    LogError("Tidepool fetch failed with http response code: \(statusCode)")
                    if statusCode == 401 {
                        failure = .unauthorized
                    }
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
    func post<P: TPPostable, T: TPFetchable>(_ postable: P, _ fetchType: T.Type, headers: [String: String]? = nil, userId: String? = nil, _ completion: @escaping (Result<T, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Post failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        var fetchForUserId = userId
        if userId == nil {
            guard let user = self.loggedInUser() else {
                LogError("Post failed, no user logged in!")
                completion(Result.failure(.notLoggedIn))
                return
            }
            fetchForUserId = user.userId
        }
        let urlExtension = P.urlExtension(forUser: fetchForUserId!)
        
        guard let body = postable.postBodyData() else {
            LogError("Post failed, no data to post!")
            completion(Result.failure(.internalError))
            return
        }
        
        sendRequest("POST", urlExtension: urlExtension,  contentType: .json, headers: headers, body: body) {
            result -> Void in
            
            // did the call happen? Typical fail case here would be offline
            guard case .success(let sendRequestResponse) = result else {
                var failure = TidepoolKitError.serviceError
                if case .failure(let error) = result {
                    LogError("Tidepool fetch failed with error: \(error)!")
                    failure = error
                }
                completion(Result.failure(failure))
                return
            }
            
            guard (sendRequestResponse.isSuccess()) else {
                var failure = TidepoolKitError.serviceError
                if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    LogError("Tidepool post failed with http response code: \(statusCode)")
                    if statusCode == 401 {
                        failure = .unauthorized
                    }
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
    func upload<T: TPUploadable>(_ uploadable: T, httpMethod: String, _ completion: @escaping (Result<[Int]?, TidepoolKitError>) -> (Void)) {
        
        guard isConnectedToNetwork() else {
            LogError("Post failed, network offline!")
            completion(Result.failure(.offline))
            return
        }
        
        guard let uploadId = currentUploadId.value else {
            LogError("Upload failed, no current uploadId!")
            // shouldn't get this far: caller of upload should check for this!
            completion(Result.failure(.internalError))
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
                var failure = TidepoolKitError.serviceError
                if case .failure(let error) = result {
                    LogError("Tidepool upload failed with error: \(error)!")
                    failure = error
                }
                completion(Result.failure(failure))
                return
            }
            
            guard (sendRequestResponse.isSuccess()) else {
                var failure = TidepoolKitError.serviceError
                 if let statusCode = sendRequestResponse.httpResponse?.statusCode {
                    LogError("Tidepool upload failed with http response code: \(statusCode)")
                    if statusCode == 401 {
                        failure = .unauthorized
                    } else if statusCode == 400 {
                        // Note: not all 400 errors are the result of samples that fail service validation.
                        // Note: the success at this level will be turned into an error at the calling level, this is just done here since the failure path doesn't carry data...
                        failure = .badRequest
                        if let data = sendRequestResponse.data {
                            let badSamples = uploadable.parseErrResponse(data)
                            completion(Result.success(badSamples))
                            return
                        }
                    }
                }
                LogError("Tidepool upload failed!")
                completion(Result.failure(failure))
                return
            }
            
            completion(Result.success(nil))
        }
    }

    //
    // MARK: - Private methods for upload support
    //
    
    /// Call this if currentUploadId is nil, before uploading data, after fetching user profile, to ensure we have a dataset id for data uploads (if so enabled)
    /// - parameter dataset: The service is queried to find an existing dataset that matches this; if no existing match is found, a new dataset will be created.
    /// - parameter completion: Method that will be called when this async operation has completed. If successful, currentUploadId in TidepoolMobileDataController will be set; if not, it will still be nil.
    func configureUploadId(_ configDataset: TPDataset, _ completion: @escaping () -> (Void)) {
        
        guard currentUploadId.value == nil else {
            LogInfo("UploadId is not nil")
            completion()
            return
        }

        // TODO: should also verify that this is a DSAUser... i.e., has a profile in the user. Something we should fetch and persist, so the TPUser object includes a persisted isDSAUser field.
        
        // if we don't have a currentUploadId yet, first try fetching one from the server that matches the one passed in...
        self.fetchDataset(configDataset) {
            result in
            switch result {
            case .success(let dataSet):
                LogInfo("configureUploadId fetch succeeded: \n\(dataSet.debugDescription)")
                if let uploadId = dataSet?.uploadId {
                    self.currentUploadId.value = uploadId
                    completion()
                    return
                }
                // no uploadId found, fall through and create one...
            case .failure(let error):
                LogError("configureUploadId fetchDataset failed! Error: \(error)")
                // network failure for fetchDataset, don't try creating a new one in case one already does exist...
                completion()
                return
            }

            // TODO: skip create until fetch actually works!
            //completion()
            //return
                
            // No matching existing dataset found, try creating a new one...
            LogInfo("Dataset for current client/version not found, try creating new dataset!")
            self.createDataset(configDataset) {
                result in
                switch result {
                case .success(let dataset):
                    LogInfo("New dataset created: \(dataset!.debugDescription)")
                    self.currentUploadId.value = dataset?.uploadId
                case .failure(let error):
                    LogError("Unable to fetch existing upload dataset or create a new one! Error: \(error)")
                }
                completion()
            }
        }
    }
    
    /// Ask service for the existing mobile app upload id for this client and version, if one exists.
    /// - parameter completion: Method that accepts a Result. Failure code is returned if network fetch of dataset array fails, otherwise success is returned. The success value will be nil, or an APIDataSet object if there is one matching the current client and version.
    private func fetchDataset(_ configDataset: TPDataset, _ completion: @escaping (Result<APIDataSet?, TidepoolKitError>) -> (Void)) {
        LogInfo("Try fetching existing dataset!")
        
        self.fetch(APIDataSetArray.self) {
            result in
            switch result {
            case .success(let apiDataSetArray):
                LogInfo("APIDataSetArray fetch succeeded: \n\(apiDataSetArray.debugDescription)")
                // fetch latest client name and version values (may have been updated by framework client)
                var result: APIDataSet?
                for dataSet in apiDataSetArray.dataSetArray {
                    if dataSet.matchesDataset(configDataset) {
                        LogInfo("Found dataset matching configDataset (\(configDataset.debugDescription))")
                        result = dataSet
                        break
                    }
                }
                completion(.success(result))
            case .failure(let error):
                LogError("APIDataSetArray fetch failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    /// Ask service to create a new upload id. Should only be called after fetchDataSet returns a nil array (no existing upload id).
    /// - parameter completion: Method that accepts an optional APIDataSet if the create succeeds, and an error result if not.
    private func createDataset(_ configDataset: TPDataset, _ completion: @escaping (Result<APIDataSet?, TidepoolKitError>) -> (Void)) {
        LogInfo("Try creating a new dataset!")
        
        self.post(APIDataSet(configDataset), APIDataSet.self) {
            result in
            switch result {
            case .success(let apiDataSet):
                NSLog("createDataset post succeeded: \n\(apiDataSet.debugDescription)")
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
            guard let token = sessionTokenSetting.value else {
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

        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            (data, response, error) -> Void in
            DispatchQueue.main.async(execute: {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
