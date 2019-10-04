//
//  TPKitTests_Mock_00Login.swift
//  TidepoolKitTests
//
//  Created by Larry Kenyon on 9/22/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
@testable import TidepoolKit

class TPKitTestsMock_00Login: TPKitTestsBase {
    
    func test01LoginMockErrorCases() {
        NSLog("\(#function)")
        let expectation = self.expectation(description: "All login test cases complete")
        let tpKit = getTpKitSingleton()
        if tpKit.isLoggedIn() {
            tpKit.logOut() {
                _ in
            }
        }
        let mockNetworkInterface = TestNetworkInterfaceLogin(tpKit)
        tpKit.configureNetworkInterface(mockNetworkInterface)
        // add .succeed at end since all tests assume we are logged out.
        let errorTestCases: [TestLoginInjectError] = [
            .returnError, .returnNilResponse, .returnNoUser, .returnNoData, .returnNoToken, .returnUnauthorized, .succeed
        ]
        runLoginMockCases(errorTestCases, mockNetwork: mockNetworkInterface) {
            expectation.fulfill()
        }
        // Wait a second for all error cases to run (using the mock interface, this should be almost instantaneous). If not, fail.
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    func runLoginMockCases(_ errorTestCases: [TestLoginInjectError], mockNetwork: TestNetworkInterfaceLogin, completion: @escaping () -> Void) {
        NSLog("\(#function)")
        if errorTestCases.isEmpty {
            completion()
            return
        }
        var remainingCases = errorTestCases
        let errorCase = remainingCases.remove(at: 0)
        runLoginMockCase(errorCase, mockNetwork: mockNetwork) {
            errorCase in
            NSLog("Completed login error case \(errorCase)")
            // recursively call to run all cases...
            self.runLoginMockCases(remainingCases, mockNetwork: mockNetwork, completion: completion)
        }
    }
    
    func runLoginMockCase(_ errorCase: TestLoginInjectError, mockNetwork: TestNetworkInterfaceLogin, completion: @escaping (TestLoginInjectError) -> Void) {
        NSLog("runLoginMockCase errorCase: \(errorCase)")
        let tpKit = getTpKitSingleton()
        mockNetwork.loginInjectError = errorCase
        tpKit.logIn(with: testEmail, password: testPassword, serverHost: testServerHost) {
            result in
            switch result {
            case .success:
                NSLog("Test login error case \(errorCase) login result == success")
                if errorCase != .succeed {
                    XCTFail("Expected login to fail!")
                }
            case .failure(let error):
                NSLog("Test login error case \(errorCase) login result error: \(error)")
                if errorCase == .succeed {
                    XCTFail("Expected login to succeed!")
                } else {
                    switch error {
                    case .unauthorized:
                        if errorCase != .returnUnauthorized {
                            XCTFail("expected unauthorized error!")
                        } else {
                            NSLog("Test passed, expected unauthorized error received!")
                        }
                    case .badLoginResponse(let errDescription):
                        NSLog("badLoginResponse description: \(errDescription ?? "")")
                        switch errorCase {
                        case .returnNoData:
                            XCTAssert(errDescription == "Login returned token but no data!")
                        case .returnNoToken:
                            XCTAssert(errDescription == "Login response contained no token in header!")
                        case .returnNoUser:
                            XCTAssert(errDescription == "Login json response not parseable as TPUser!")
                        default:
                            XCTFail("Did not expect .badLoginResponse error!")
                        }
                    case .serviceError(let code):
                        if errorCase == .returnNilResponse {
                            XCTAssert(code == nil)
                        } else if errorCase == .returnError {
                            XCTAssert(code == 504)
                        } else {
                            XCTFail("did not expect .service error, code: \(String(describing: code))")
                        }
                    default:
                        XCTFail("expected a different error result!")
                    }
                }
            }
            completion(errorCase)
        }
    }
}

enum TestLoginInjectError {
    case succeed // will return a fake token and user...
    case returnError
    case returnUnauthorized
    case returnNilResponse
    case returnNoToken
    case returnNoData
    case returnNoUser
}

/// This class mocks the network for login calls only, injecting various login errors...
class TestNetworkInterfaceLogin: TestNetworkInterface {
    
    var loginInjectError: TestLoginInjectError = .succeed
    
    override func sendStandardRequest(_ request: URLRequest, completion: @escaping NetworkRequestCompletionHandler) {
        guard let urlStr = request.url?.absoluteString else {
            NSLog("ERROR: \(#function) found no url!")
            return
        }
        guard let method = request.httpMethod else {
            NSLog("ERROR: \(#function) found no method!")
            return
        }
        NSLog("TestNetworkInterfaceLogin url: \(urlStr)")
        guard urlStr.hasSuffix("/auth/login?") else {
            tidepoolNetworkInterface.sendStandardRequest(request, completion: completion)
            return
        }
        guard method == "POST" else {
            tidepoolNetworkInterface.sendStandardRequest(request, completion: completion)
            return
        }
        NSLog("mock network intercepting sendRequest \(method)) url: \(urlStr)")
        
        // just add a tenth of a second delay to simulate the network...
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
         
            let data: Data? = nil
            var response: URLResponse? = nil
            let error: Error?  = nil
            
            NSLog("mock network simulating error: \(self.loginInjectError)")
            switch self.loginInjectError {
            case .succeed:
                let headers: [String: String] = [
                    "x-tidepool-session-token" : "test token"
                ]
                let data = """
                {
                    "emailVerified": true,
                    "emails": ["larry+kittest@tidepool.org"],
                    "termsAccepted": "2019-06-24T06:24:47-07:00",
                    "userid": "1d51c27fbd",
                    "username": "larry+kittest@tidepool.org"
                }
                """.data(using: .utf8)!
                response = HTTPURLResponse(url: URL(string: "https://stg-api.tidepool.org/auth/login?")!, statusCode: 200, httpVersion: nil, headerFields: headers)
                completion(data, response, error)
                return
                
            case .returnUnauthorized:
                response = HTTPURLResponse(url: URL(string: "https://stg-api.tidepool.org/auth/login?")!, statusCode: 401, httpVersion: nil, headerFields: nil)
                completion(data, response, error)
                return
                
            case .returnError:
                response = HTTPURLResponse(url: URL(string: "https://stg-api.tidepool.org/auth/login?")!, statusCode: 504, httpVersion: nil, headerFields: nil)
                completion(data, response, error)

            case .returnNilResponse:
                completion(data, response, error)

            case .returnNoToken:
                let headers: [String: String] = [:]
                response = HTTPURLResponse(url: URL(string: "https://stg-api.tidepool.org/auth/login?")!, statusCode: 200, httpVersion: nil, headerFields: headers)
                completion(data, response, error)

            case .returnNoData:
                let headers: [String: String] = [
                    "x-tidepool-session-token" : "test token"
                ]
                response = HTTPURLResponse(url: URL(string: "https://stg-api.tidepool.org/auth/login?")!, statusCode: 200, httpVersion: nil, headerFields: headers)
                completion(data, response, error)

            case .returnNoUser:
                 let headers: [String: String] = [
                    "x-tidepool-session-token" : "test token"
                ]
                response = HTTPURLResponse(url: URL(string: "https://stg-api.tidepool.org/auth/login?")!, statusCode: 200, httpVersion: nil, headerFields: headers)
                completion(Data(), response, error)
            }
        }
    }
}
