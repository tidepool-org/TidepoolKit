//
//  TAPI.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 1/20/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

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
    public init() {
        self.environmentsLocked = Locked(TAPI.defaultEnvironments)
        self.urlSessionConfigurationLocked = Locked(TAPI.defaultURLSessionConfiguration)
        self.urlSessionLocked = Locked(nil)
        fetchEnvironments()
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
                    if let completion = completion {
                        completion(.failure(.network(error)))
                    } else {
                        TSharedLogging.error("Failure during DNS SRV record lookup: \(error)")
                    }
                case .success(let records):
                    let environments = (TAPI.DNSSRVRecordsImplicit + records).environments
                    self.environmentsLocked.mutate { $0 = environments }
                    if let completion = completion {
                        completion(.success(environments))
                    } else {
                        TSharedLogging.debug("Successful DNS SRV record lookup")
                    }
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
        request.setValue(basicAuthorizationFromCredentials(email: email, password: password), forHTTPHeaderField: "Authorization")
        performRequest(request) { (result: Result<(HTTPURLResponse, Data?), TError>) -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response, let data):
                if let authenticationToken = response.value(forHTTPHeaderField: "X-Tidepool-Session-Token"),
                    let data = data,
                    let dictionaryArray = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let login = Login(rawValue: dictionaryArray) {
                    completion(.success(TSession(environment: environment, authenticationToken: authenticationToken, userID: login.userID)))
                } else {
                    completion(.failure(.badResponse(response, data)))
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
        performRequest(request) { (result: Result<(HTTPURLResponse, Data?), TError>) -> Void in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response, let data):
                if let authenticationToken = response.value(forHTTPHeaderField: "X-Tidepool-Session-Token") {
                    completion(.success(TSession(environment: session.environment, authenticationToken: authenticationToken, userID: session.userID)))
                } else {
                    completion(.failure(.badResponse(response, data)))
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
        performRequest(createRequest(session: session, method: "POST", path: "/auth/logout"), completion: completion)
    }

    // MARK: - Internal Implementation

    private func createRequest(session: TSession, method: String, path: String, queryItems: [URLQueryItem]? = nil) -> URLRequest {
        var request = createRequest(environment: session.environment, method: method, path: path, queryItems: queryItems)
        request.setValue(session.authenticationToken, forHTTPHeaderField: "X-Tidepool-Session-Token")
        return request
    }

    private func createRequest(environment: TEnvironment, method: String, path: String, queryItems: [URLQueryItem]? = nil) -> URLRequest {
        var request = URLRequest(url: environment.url(path: path, queryItems: queryItems))
        request.httpMethod = method
        return request
    }

    private func performRequest(_ request: URLRequest, completion: @escaping (TError?) -> Void) {
        performRequest(request) { (result: Result<(HTTPURLResponse, Data?), TError>) -> Void in
            switch result {
            case .failure(let error):
                completion(error)
            case .success(_, _):
                completion(nil)
            }
        }
    }

    private func performRequest(_ request: URLRequest, completion: @escaping (Result<(HTTPURLResponse, Data?), TError>) -> Void) {
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(.network(error)))
            } else {
                completion(self.processStatusCode(response: response as! HTTPURLResponse, data: data))
            }
        }
        task.resume()
    }

    private func processStatusCode(response: HTTPURLResponse, data: Data?) -> Result<(HTTPURLResponse, Data?), TError> {
        let statusCode = response.statusCode
        switch statusCode {
        case 200...299:
            return .success((response, data))
        case 400:
            return .failure(.badRequest(response, data))
        case 401:
            return .failure(.unauthenticated(response, data))
        case 403:
            return .failure(.unauthorized(response, data))
        case 404:
            return .failure(.notFound(response, data))
        default:
            return .failure(.unexpectedStatusCode(response, data))
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
        urlSessionConfiguration.httpAdditionalHeaders!["User-Agent"] = TAPI.defaultUserAgent
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

    private static let DNSSRVRecordsImplicit = [DNSSRVRecord(priority: UInt16.min, weight: UInt16.max, port: 443, host: "app.tidepool.org")]
}

public struct Login {
    public typealias RawValue = [String: Any]

    public let userID: String
    public let email: String
    public let emailVerified: Bool
    public let termsAccepted: String?

    public init?(rawValue: RawValue) {
        guard let userID = rawValue["userid"] as? String,
            let email = rawValue["username"] as? String,
            let emailVerified = rawValue["emailVerified"] as? Bool else
        {
            return nil
        }

        self.userID = userID
        self.email = email
        self.emailVerified = emailVerified
        self.termsAccepted = rawValue["termsAccepted"] as? String
    }
}
