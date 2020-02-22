//
//  TAPITests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 3/3/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import XCTest
@testable import TidepoolKit

class TAPITests: XCTestCase {
    var api: TAPI!
    var environment: TEnvironment!
    let authenticationToken = randomString
    let userId = randomString

    override func setUp() {
        super.setUp()

        self.api = TAPI(automaticallyFetchEnvironments: false)
        self.api.urlSessionConfiguration.protocolClasses = [URLProtocolMock.self]
        self.environment = TEnvironment(host: "test.org", port: 443)
    }

    static var randomString: String { UUID().uuidString }

    struct TestError: Error {}
}

class TAPIEnvironmentTests: TAPITests {
    func testDefaultEnvironment() {
        XCTAssertEqual(api.environments, [TEnvironment(host: "app.tidepool.org", port: 443)])
    }
}

class TAPIURLSessionConfigurationTests: TAPITests {
    func testDefaultURLSessionConfiguration() {
        let urlSessionConfiguration = api.urlSessionConfiguration
        XCTAssertEqual(urlSessionConfiguration.waitsForConnectivity, true)
        XCTAssertNotNil(urlSessionConfiguration.httpAdditionalHeaders)
        XCTAssertNotNil(urlSessionConfiguration.httpAdditionalHeaders?["User-Agent"])
        XCTAssertNotNil(urlSessionConfiguration.protocolClasses)
    }
}

class TAPILoginTests: TAPITests {
    let email = randomString
    let password = randomString

    override func setUp() {
        super.setUp()

        URLProtocolMock.validator = URLProtocolMock.Validator(url: "https://test.org/auth/login",
                                                              method: "POST",
                                                              headers: ["Authorization": "Basic \(Data("\(email):\(password)".utf8).base64EncodedString())"])
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 201,
                                                          headers: ["X-Tidepool-Session-Token": authenticationToken],
                                                          body: LoginResponse(userId: userId, email: email, emailVerified: true, termsAccepted: "2010-01-01T12:34:56Z"))
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard case .failure(let error) = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard case .failure(let error) = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testRequestEmailNotVerified() {
        URLProtocolMock.success?.statusCode = 403
        guard case .failure(let error) = performRequest(), case .requestEmailNotVerified = error else {
            XCTFail()
            return
        }
    }

    func testResponseNotAuthenticated() {
        URLProtocolMock.success?.headers = nil
        guard case .failure(let error) = performRequest(), case .responseNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testResponseMalformedJSON() {
        URLProtocolMock.success?.body = nil
        guard case .failure(let error) = performRequest(), case .responseMalformedJSON = error else {
            XCTFail()
            return
        }
    }

    func testTermsOfUseNotAccepted() {
        URLProtocolMock.success?.set(body: LoginResponse(userId: userId, email: email, emailVerified: true))
        guard case .failure(let error) = performRequest(), case .requestTermsOfServiceNotAccepted = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard case .success(let session) = performRequest() else {
            XCTFail()
            return
        }
        XCTAssertEqual(session.environment, self.environment)
        XCTAssertEqual(session.authenticationToken, authenticationToken)
        XCTAssertEqual(session.userId, userId)
        XCTAssertNotNil(session.trace)
    }

    private func performRequest() -> Result<TSession, TError>? {
        let expectation = XCTestExpectationWithResult<TSession, TError>()
        api.login(environment: environment, email: email, password: password) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.result
    }
}

class TAPISessionTests: TAPITests {
    var session: TSession!
    var headers: [String: String]!

    override func setUp() {
        super.setUp()

        session = TSession(environment: environment, authenticationToken: authenticationToken, userId: userId)
        headers = ["X-Tidepool-Session-Token": authenticationToken, "X-Tidepool-Trace-Session": session.trace!]
    }
}

class TAPIRefreshTests: TAPISessionTests {
    let refreshedAuthenticationToken = randomString

    override func setUp() {
        super.setUp()

        URLProtocolMock.validator = URLProtocolMock.Validator(url: "https://test.org/auth/login", method: "GET", headers: headers)
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 200, headers: ["X-Tidepool-Session-Token": refreshedAuthenticationToken])
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard case .failure(let error) = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard case .failure(let error) = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testResponseNotAuthenticated() {
        URLProtocolMock.success?.headers = nil
        guard case .failure(let error) = performRequest(), case .responseNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard case .success(let refreshedSession) = performRequest() else {
            XCTFail()
            return
        }
        XCTAssertEqual(refreshedSession.environment, session.environment)
        XCTAssertNotEqual(refreshedSession.authenticationToken, session.authenticationToken)
        XCTAssertEqual(refreshedSession.userId, session.userId)
        XCTAssertEqual(refreshedSession.trace, session.trace)
    }

    private func performRequest() -> Result<TSession, TError>? {
        let expectation = XCTestExpectationWithResult<TSession, TError>()
        api.refresh(session: session) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.result
    }
}

class TAPILogoutTests: TAPISessionTests {
    override func setUp() {
        super.setUp()

        URLProtocolMock.validator = URLProtocolMock.Validator(url: "https://test.org/auth/logout", method: "POST", headers: headers)
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 200)
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard let error = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard let error = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard performRequest() == nil else {
            XCTFail()
            return
        }
    }

    private func performRequest() -> TError? {
        let expectation = XCTestExpectationWithError()
        api.logout(session: session) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.error
    }
}

class TAPIGetProfileTests: TAPISessionTests {
    override func setUp() {
        super.setUp()

        URLProtocolMock.validator = URLProtocolMock.Validator(url: "https://test.org/metadata/\(userId)/profile", method: "GET", headers: headers)
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 200, headers: headers, body: TProfileTests.profile)
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard case .failure(let error) = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard case .failure(let error) = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testRequestNotAuthorized() {
        URLProtocolMock.success?.statusCode = 403
        guard case .failure(let error) = performRequest(), case .requestNotAuthorized = error else {
            XCTFail()
            return
        }
    }

    func testResponseMalformedJSON() {
        URLProtocolMock.success?.body = nil
        guard case .failure(let error) = performRequest(), case .responseMalformedJSON = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard case .success(let profile) = performRequest() else {
            XCTFail()
            return
        }
        XCTAssertEqual(profile, TProfileTests.profile)
    }

    private func performRequest() -> Result<TProfile, TError>? {
        let expectation = XCTestExpectationWithResult<TProfile, TError>()
        api.getProfile(session: session) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.result
    }
}

class TAPIListDataSetsTests: TAPISessionTests {
    override func setUp() {
        super.setUp()

        let url = "https://test.org/v1/users/\(userId)/data_sets?client.name=org.tidepool.Example&deleted=true&deviceId=ExampleDeviceId"
        URLProtocolMock.validator = URLProtocolMock.Validator(url: url, method: "GET", headers: headers)
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 200, headers: headers, body: [TDataSetTests.dataSet])
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard case .failure(let error) = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard case .failure(let error) = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testRequestNotAuthorized() {
        URLProtocolMock.success?.statusCode = 403
        guard case .failure(let error) = performRequest(), case .requestNotAuthorized = error else {
            XCTFail()
            return
        }
    }

    func testResponseMalformedJSON() {
        URLProtocolMock.success?.body = nil
        guard case .failure(let error) = performRequest(), case .responseMalformedJSON = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard case .success(let dataSets) = performRequest() else {
            XCTFail()
            return
        }
        XCTAssertEqual(dataSets, [TDataSetTests.dataSet])
    }

    private func performRequest() -> Result<[TDataSet], TError>? {
        let expectation = XCTestExpectationWithResult<[TDataSet], TError>()
        api.listDataSets(filter: TDataSetFilterTests.filter, session: session) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.result
    }
}

class TAPICreateDataSetTests: TAPISessionTests {
    var dataSet: TDataSet!

    override func setUp() {
        super.setUp()

        dataSet = TDataSet(dataSetType: .continuous, client: TDataSetClientTests.client, deduplicator: TDataSet.Deduplicator(name: .dataSetDeleteOrigin))
        URLProtocolMock.validator = URLProtocolMock.Validator(url: "https://test.org/v1/users/\(userId)/data_sets", method: "POST", headers: headers, body: dataSet)
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 200, headers: headers, body: LegacyResponse.Success(data: TDataSetTests.dataSet))
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard case .failure(let error) = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard case .failure(let error) = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testRequestNotAuthorized() {
        URLProtocolMock.success?.statusCode = 403
        guard case .failure(let error) = performRequest(), case .requestNotAuthorized = error else {
            XCTFail()
            return
        }
    }

    func testResponseMalformedJSON() {
        URLProtocolMock.success?.body = nil
        guard case .failure(let error) = performRequest(), case .responseMalformedJSON = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard case .success(let createdDataSet) = performRequest() else {
            XCTFail()
            return
        }
        XCTAssertEqual(createdDataSet, TDataSetTests.dataSet)
    }

    private func performRequest() -> Result<TDataSet, TError>? {
        let expectation = XCTestExpectationWithResult<TDataSet, TError>()
        api.createDataSet(dataSet, session: session) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.result
    }
}

class TAPIListDataTests: TAPISessionTests {
    override func setUp() {
        super.setUp()

        let url = "https://test.org/data/\(userId)?startDate=\(Date.testJSONString)"
        URLProtocolMock.validator = URLProtocolMock.Validator(url: url, method: "GET", headers: headers)
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 200, headers: headers, body: [TCBGDatumTests.cbg, TFoodDatumTests.food])
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard case .failure(let error) = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard case .failure(let error) = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testRequestNotAuthorized() {
        URLProtocolMock.success?.statusCode = 403
        guard case .failure(let error) = performRequest(), case .requestNotAuthorized = error else {
            XCTFail()
            return
        }
    }

    func testResponseMalformedJSON() {
        URLProtocolMock.success?.body = nil
        guard case .failure(let error) = performRequest(), case .responseMalformedJSON = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard case .success((let data, let malformed)) = performRequest() else {
            XCTFail()
            return
        }
        XCTAssertEqual(data, [TCBGDatumTests.cbg, TFoodDatumTests.food])
        XCTAssertEqual(malformed.count, 0)
    }

    private func performRequest() -> Result<([TDatum], [Int: [String:Any]]), TError>? {
        let expectation = XCTestExpectationWithResult<([TDatum], [Int: [String:Any]]), TError>()
        api.listData(filter: TDatum.Filter(startDate: Date.test), session: session) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.result
    }
}

class TAPICreateDataTests: TAPISessionTests {
    let dataSetId = randomString
    let data = [TCBGDatumTests.cbg, TFoodDatumTests.food]

    override func setUp() {
        super.setUp()

        URLProtocolMock.validator = URLProtocolMock.Validator(url: "https://test.org/v1/data_sets/\(dataSetId)/data", method: "POST", headers: headers, body: data)
        URLProtocolMock.error = nil
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 200, headers: headers, body: LegacyResponse.Success<DataResponse>(data: DataResponse()))
    }

    func testNetworkError() {
        URLProtocolMock.error = TestError()
        guard let error = performRequest(), case .network(let networkError) = error else {
            XCTFail()
            return
        }
        XCTAssertNotNil(networkError as? TestError)
    }

    func testRequestNotAuthenticated() {
        URLProtocolMock.success?.statusCode = 401
        guard let error = performRequest(), case .requestNotAuthenticated = error else {
            XCTFail()
            return
        }
    }

    func testRequestNotAuthorized() {
        URLProtocolMock.success?.statusCode = 403
        guard let error = performRequest(), case .requestNotAuthorized = error else {
            XCTFail()
            return
        }
    }

    func testRequestMalformedJSON() {
        let errors = [TError.Detail(code: "code-123", title: "title-123", detail: "detail-123"),
                      TError.Detail(code: "code-456", title: "title-456", detail: "detail-456"),
                      TError.Detail(code: "code-789", title: "title-789", detail: "detail-789")]
        URLProtocolMock.success = URLProtocolMock.Success(statusCode: 400, headers: headers, body: LegacyResponse.Failure(errors: errors))
        guard let error = performRequest(), case .requestMalformedJSON(_, _, let malformedJSONErrors) = error else {
            XCTFail()
            return
        }
        XCTAssertEqual(malformedJSONErrors, errors)
    }

    func testResponseMalformedJSON() {
        URLProtocolMock.success?.body = nil
        guard let error = performRequest(), case .responseMalformedJSON = error else {
            XCTFail()
            return
        }
    }

    func testSuccess() {
        guard performRequest() == nil else {
            XCTFail()
            return
        }
    }

    private func performRequest() -> TError? {
        let expectation = XCTestExpectationWithError()
        api.createData(data, dataSetId: dataSetId, session: session) { expectation.fulfill($0) }
        XCTAssertNotEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .timedOut)
        return expectation.error
    }
}
