//
//  TAPI.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 1/20/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation

/// The Tidepool API
public class TAPI {

    /// All currently known environments. Will always include, as the first element, production. It will additionally include any
    /// environments discovered from the latest DNS SRV record lookup. When an instance of TAPI is created it will automatically
    /// perform a DNS SRV record lookup in the background. A client should generally only have one instance of TAPI.
    public var environments: [TEnvironment] { environmentsLocked.value }

    /// The URLSessionConfiguration used for all requests. The default is typically acceptable for most purposes. Any changes
    /// will only apply to subsequent requests.
    public var urlSessionConfiguration: URLSessionConfiguration {
        get {
            return urlSessionConfigurationLocked.value
        }
        set {
            urlSessionConfigurationLocked.mutate { $0 = newValue }
            urlSessionLocked.mutate { $0 = nil }
        }
    }

    /// Create a new instance of TAPI. Automatically lookup additional environments in the background.
    ///
    /// - Parameters:
    ///   - automaticallyFetchEnvironments: Automatically fetch an updated list of environments when created.
    public init(automaticallyFetchEnvironments: Bool = true) {
        self.environmentsLocked = Locked(TAPI.defaultEnvironments)
        self.urlSessionConfigurationLocked = Locked(TAPI.defaultURLSessionConfiguration)
        self.urlSessionLocked = Locked(nil)
        if automaticallyFetchEnvironments {
            fetchEnvironments()
        }
    }

    // MARK: - Environment

    /// Manually fetch the latest environments. Production is always the first element.
    ///
    /// - Parameters:
    ///   - completion: The completion function to invoke with the latest environments or any error.
    public func fetchEnvironments(completion: ((Result<[TEnvironment], TError>) -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            DNS.lookupSRVRecords(for: TAPI.DNSSRVRecordsDomainName) { result in
                switch result {
                case .failure(let error):
                    TSharedLogging.error("Failure during DNS SRV record lookup [\(error)]")
                    completion?(.failure(.network(error)))
                case .success(let records):
                    var records = records + TAPI.DNSSRVRecordsImplicit
                    records = records.map { record in
                        if record.host != "localhost" {
                            return record
                        }
                        return DNSSRVRecord(priority: UInt16.max, weight: record.weight, host: record.host, port: record.port)
                    }
                    let environments = records.sorted().environments
                    self.environmentsLocked.mutate { $0 = environments }
                    TSharedLogging.debug("Successful DNS SRV record lookup")
                    completion?(.success(environments))
                }
            }
        }
    }

    // MARK: - Authentication

    /// Login to the Tidepool environment using the email and password. This is not typically invoked directly, but instead is
    /// used internally by the LoginSignupViewController.
    ///
    /// - Parameters:
    ///   - environment: The environment to login.
    ///   - email: The email to use for login.
    ///   - password: The password to use for login.
    ///   - completion: The completion function to invoke with the newly created session or an error.
    public func login(environment: TEnvironment, email: String, password: String, completion: @escaping (Result<TSession, TError>) -> Void) {
        var request = createRequest(environment: environment, method: "POST", path: "/auth/login")
        request?.setValue(basicAuthorizationFromCredentials(email: email, password: password), forHTTPHeaderField: HTTPHeaderField.authorization.rawValue)
        performRequest(request) { (result: DecodableHTTPResult<LoginResponse>) -> Void in
            switch result {
            case .failure(let error):
                switch error {
                case .requestNotAuthorized(let response, let data):     // CUSTOM: Backend currently returns status code 403 to imply email not verified
                    completion(.failure(.requestEmailNotVerified(response, data)))
                default:
                    completion(.failure(error))
                }
            case .success((let response, let data, let loginResponse)):
                if let authenticationToken = response.value(forHTTPHeaderField: "X-Tidepool-Session-Token"), !authenticationToken.isEmpty {
                    if loginResponse.termsAccepted?.isEmpty == false {     // CUSTOM: Backend does not currently explicitly check if terms are accepted
                        completion(.success(TSession(environment: environment, authenticationToken: authenticationToken, userId: loginResponse.userId)))
                    } else {
                        completion(.failure(.requestTermsOfServiceNotAccepted(response, data)))
                    }
                } else {
                    completion(.failure(.responseNotAuthenticated(response, data)))
                }
            }
        }
    }

    private func basicAuthorizationFromCredentials(email: String, password: String) -> String {
        let encodedCredentials = Data("\(email):\(password)".utf8).base64EncodedString()
        return "Basic \(encodedCredentials)"
    }

    /// Refresh the given Tidepool API session. If successful, the completion handler should replace
    /// the old session with the new session. Upon failure, the completion handler should forget the
    /// old session.
    ///
    /// An .unauthenticated error indicates that the old session is no longer valid. All other errors
    /// indicate that the old session is still valid and refresh can be retried.
    ///
    /// - Parameters:
    ///   - session: The Tidepool API session to refresh.
    ///   - completion: The completion function to invoke with the updated session or any error.
    public func refresh(session: TSession, completion: @escaping (Result<TSession, TError>) -> Void) {
        let request = createRequest(session: session, method: "GET", path: "/auth/login")
        performRequest(request) { (result: HTTPResult) -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success((let response, let data)):
                if let authenticationToken = response.value(forHTTPHeaderField: "X-Tidepool-Session-Token"), !authenticationToken.isEmpty {
                    completion(.success(TSession(environment: session.environment, authenticationToken: authenticationToken, userId: session.userId, trace: session.trace)))
                } else {
                    completion(.failure(.responseNotAuthenticated(response, data)))
                }
            }
        }
    }

    /// Logout the given Tidepool API session. The completion handler should forget the old session.
    ///
    /// - Parameters:
    ///   - session: The Tidepool API session to logout.
    ///   - completion: The completion function to invoke with any error.
    public func logout(session: TSession, completion: @escaping (TError?) -> Void) {
        let request = createRequest(session: session, method: "POST", path: "/auth/logout")
        performRequest(request, completion: completion)
    }

    // MARK: - Profile

    /// Get the profile for the specified user id. If no user id is specified, then the session user id is used.
    ///
    /// - Parameters:
    ///   - userId: The user id for which to get the profile. If no user id is specified, then the session user id is used.
    ///   - session: The Tidepool API session to use.
    ///   - completion: The completion function to invoke with any error.
    public func getProfile(userId: String? = nil, session: TSession, completion: @escaping (Result<TProfile, TError>) -> Void) {
        let request = createRequest(session: session, method: "GET", path: "/metadata/\(userId ?? session.userId)/profile")
        performRequest(request, completion: completion)
    }

    // MARK: - Data Sets

    /// List the data sets for the specified user id. If no user id is specified, then the session user id is used. A filter can
    /// be specified to reduce the data sets returned.
    ///
    /// - Parameters:
    ///   - filter: The filter to use when requesting the data sets.
    ///   - userId: The user id for which to get the data sets. If no user id is specified, then the session user id is used.
    ///   - session: The Tidepool API session to use.
    ///   - completion: The completion function to invoke with any error.
    public func listDataSets(filter: TDataSet.Filter? = nil, userId: String? = nil, session: TSession, completion: @escaping (Result<[TDataSet], TError>) -> Void) {
        let request = createRequest(session: session, method: "GET", path: "/v1/users/\(userId ?? session.userId)/data_sets", queryItems: filter?.queryItems)
        performRequest(request, completion: completion)
    }

    /// Create a data set for the specified user id. If no user id is specified, then the session user id is used.
    ///
    /// - Parameters:
    ///   - dataSet: The data set to create.
    ///   - userId: The user id for which to create the data set. If no user id is specified, then the session user id is used.
    ///   - session: The Tidepool API session to use.
    ///   - completion: The completion function to invoke with any error.
    public func createDataSet(_ dataSet: TDataSet, userId: String? = nil, session: TSession, completion: @escaping (Result<TDataSet, TError>) -> Void) {
        let request = createRequest(session: session, method: "POST", path: "/v1/users/\(userId ?? session.userId)/data_sets", body: dataSet)
        performRequest(request) { (result: DecodableResult<LegacyResponse.Success<TDataSet>>) -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let legacyResponse):
                completion(.success(legacyResponse.data))
            }
        }
    }

    // MARK: - Datum

    public typealias MalformedResult = [String: [String: Any]]
    public typealias DataResult = Result<([TDatum], MalformedResult), TError>

    /// List the data for the specified user id. If no user id is specified, then the session user id is used. A filter can
    /// be specified to reduce the data returned.
    ///
    /// - Parameters:
    ///   - filter: The filter to use when requesting the data.
    ///   - userId: The user id for which to get the data. If no user id is specified, then the session user id is used.
    ///   - session: The Tidepool API session to use.
    ///   - completion: The completion function to invoke with any error.
    public func listData(filter: TDatum.Filter? = nil, userId: String? = nil, session: TSession, completion: @escaping (DataResult) -> Void) {
        let request = createRequest(session: session, method: "GET", path: "/data/\(userId ?? session.userId)", queryItems: filter?.queryItems)
        performRequest(request) { (result: DecodableResult<DataResponse>) -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                completion(.success((data.data, data.malformed)))
            }
        }
    }

    /// Create data for the specified data set id.
    ///
    /// - Parameters:
    ///   - data: The data to create.
    ///   - dataSetId: The data set id for which to create the data.
    ///   - session: The Tidepool API session to use.
    ///   - completion: The completion function to invoke with any error.
    public func createData(_ data: [TDatum], dataSetId: String, session: TSession, completion: @escaping (TError?) -> Void) {
        guard !data.isEmpty else {
            completion(nil)
            return
        }

        let request = createRequest(session: session, method: "POST", path: "/v1/data_sets/\(dataSetId)/data", body: data)
        performRequest(request) { (result: DecodableResult<LegacyResponse.Success<DataResponse>>) -> Void in
            switch result {
            case .failure(let error):
                if case .requestMalformed(let response, let data) = error {
                    if let data = data {
                        if let legacyResponse = try? JSONDecoder.tidepool.decode(LegacyResponse.Failure.self, from: data) {
                            completion(.requestMalformedJSON(response, data, legacyResponse.errors))
                            return
                        } else if let error = try? JSONDecoder.tidepool.decode(TError.Detail.self, from: data) {
                            completion(.requestMalformedJSON(response, data, [error]))
                            return
                        }
                    }
                }
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }

    /// Delete data from the specified data set id.
    ///
    /// - Parameters:
    ///   - selectors: The selectors for the data to delete.
    ///   - dataSetId: The data set id from which to delete the data.
    ///   - session: The Tidepool API session to use.
    ///   - completion: The completion function to invoke with any error.
    public func deleteData(withSelectors selectors: [TDatum.Selector], dataSetId: String, session: TSession, completion: @escaping (TError?) -> Void) {
        guard !selectors.isEmpty else {
            completion(nil)
            return
        }
        
        let request = createRequest(session: session, method: "DELETE", path: "/v1/data_sets/\(dataSetId)/data", body: selectors)
        performRequest(request, completion: completion)
    }

    // MARK: - Internal - Create Request

    private func createRequest<E>(session: TSession, method: String, path: String, body: E) -> URLRequest? where E: Encodable {
        var request = createRequest(session: session, method: method, path: path)
        request?.setValue("application/json; charset=utf-8", forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        do {
            request?.httpBody = try JSONEncoder.tidepool.encode(body)
        } catch let error {
            TSharedLogging.error("Failure encoding request body [\(error)]")
            return nil
        }
        return request
    }

    private func createRequest(session: TSession, method: String, path: String, queryItems: [URLQueryItem]? = nil) -> URLRequest? {
        var request = createRequest(environment: session.environment, method: method, path: path, queryItems: queryItems)
        request?.setValue(session.authenticationToken, forHTTPHeaderField: HTTPHeaderField.tidepoolSessionToken.rawValue)
        if let trace = session.trace {
            request?.setValue(trace, forHTTPHeaderField: HTTPHeaderField.tidepoolTraceSession.rawValue)
        }
        return request
    }

    private func createRequest(environment: TEnvironment, method: String, path: String, queryItems: [URLQueryItem]? = nil) -> URLRequest? {
        guard let url = environment.url(path: path, queryItems: queryItems) else {
            TSharedLogging.error("Failure creating request URL [environment='\(environment)'; path='\(path)'; queryItems=\(String(describing: queryItems))")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        return request
    }

    // MARK: - Internal - Perform Request

    private typealias DecodableResult<D> = Result<D, TError> where D: Decodable

    private func performRequest<D>(_ request: URLRequest?, completion: @escaping (DecodableResult<D>) -> Void) where D: Decodable {
        performRequest(request) { (result: DecodableHTTPResult<D>) -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success((_, _, let decoded)):
                completion(.success(decoded))
            }
        }
    }

    private typealias DecodableHTTPResult<D> = Result<(HTTPURLResponse, Data, D), TError> where D: Decodable

    private func performRequest<D>(_ request: URLRequest?, completion: @escaping (DecodableHTTPResult<D>) -> Void) where D: Decodable {
        performRequest(request) { (result: HTTPResult) -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success((let response, let data)):
                if let data = data {
                    do {
                        completion(.success((response, data, try JSONDecoder.tidepool.decode(D.self, from: data))))
                    } catch let error {
                        completion(.failure(.responseMalformedJSON(response, data, error)))
                    }
                } else {
                    completion(.failure(.responseMissingJSON(response)))
                }
            }
        }
    }

    private func performRequest(_ request: URLRequest?, completion: @escaping (TError?) -> Void) {
        performRequest(request) { (result: HTTPResult) -> Void in
            switch result {
            case .failure(let error):
                completion(error)
            case .success:
                completion(nil)
            }
        }
    }

    private typealias HTTPResult = Result<(HTTPURLResponse, Data?), TError>

    private func performRequest(_ request: URLRequest?, completion: @escaping (HTTPResult) -> Void) {
        guard let request = request else {
            completion(.failure(.requestInvalid))
            return
        }

        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.network(error)))
            } else if let response = response as? HTTPURLResponse {
                completion(self.processStatusCode(response: response, data: data))
            } else {
                completion(.failure(.responseUnexpected(response, data)))
            }
        }
        task.resume()
    }

    private func processStatusCode(response: HTTPURLResponse, data: Data?) -> HTTPResult {
        let statusCode = response.statusCode
        switch statusCode {
        case 200...299:
            return .success((response, data))
        case 400:
            return .failure(.requestMalformed(response, data))
        case 401:
            return .failure(.requestNotAuthenticated(response, data))
        case 403:
            return .failure(.requestNotAuthorized(response, data))
        case 404:
            return .failure(.requestResourceNotFound(response, data))
        default:
            return .failure(.responseUnexpectedStatusCode(response, data))
        }
    }

    private static var defaultUserAgent: String {
        return "\(Bundle.main.userAgent) \(Bundle(for: self).userAgent) \(ProcessInfo.processInfo.userAgent)"
    }

    private static var defaultURLSessionConfiguration: URLSessionConfiguration {
        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.waitsForConnectivity = true
        if urlSessionConfiguration.httpAdditionalHeaders == nil {
            urlSessionConfiguration.httpAdditionalHeaders = [:]
        }
        urlSessionConfiguration.httpAdditionalHeaders?["User-Agent"] = TAPI.defaultUserAgent
        return urlSessionConfiguration
    }

    private var urlSessionConfigurationLocked: Locked<URLSessionConfiguration>

    private var urlSession: URLSession! {
        let urlSessionConfiguration = urlSessionConfigurationLocked.value
        return urlSessionLocked.mutate { urlSession in
            if urlSession == nil {
                urlSession = URLSession(configuration: urlSessionConfiguration)
            }
        }
    }

    private var urlSessionLocked: Locked<URLSession?>

    private static var defaultEnvironments: [TEnvironment] {
        return DNSSRVRecordsImplicit.environments
    }

    private var environmentsLocked: Locked<[TEnvironment]>

    private static let DNSSRVRecordsDomainName = "environments-srv.tidepool.org"

    private static let DNSSRVRecordsImplicit = [DNSSRVRecord(priority: UInt16.min, weight: UInt16.max, host: "app.tidepool.org", port: 443)]

    private enum HTTPHeaderField: String {
        case authorization = "Authorization"
        case contentType = "Content-Type"
        case tidepoolSessionToken = "X-Tidepool-Session-Token"
        case tidepoolTraceSession = "X-Tidepool-Trace-Session"
    }
}
