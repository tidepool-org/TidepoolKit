//
//  TPKitTests00Login.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
@testable import TidepoolKit

class TPKitTests00Login: TPKitTestsBase {

    func test01LoginBadUser() {
        let expectation = self.expectation(description: "Login call fails with unauthorized")
        let tpKit = getTpKitSingleton()
        if tpKit.isLoggedIn() {
            tpKit.logOut() {
                _ in
            }
        }
        tpKit.logIn(with: "badUserEmail@bad.com", password: testPassword, serverHost: testServerHost) {
            result in
             expectation.fulfill()
            switch result {
            case .success:
                XCTFail("Expected login to fail with bad user email!")
            case .failure(let error):
                NSLog("login with bad user returned: \(error)")
                switch error {
                case .unauthorized:
                    NSLog("Test passed, expected unauthorized error received!")
                default:
                    XCTFail("expected unauthorized error!")
                }
            }
        }
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test02Login() {
        let expectation = self.expectation(description: "login call completes")
        let tpKit = getTpKitSingleton()
        if tpKit.isLoggedIn() {
            tpKit.logOut() { _ in }
        }
        tpKit.logIn(with: testEmail, password: testPassword, serverHost: testServerHost) {
            result in
            expectation.fulfill()
            switch result {
            case .success(let session):
                XCTAssert(session.user.userEmail != nil)
                XCTAssert(session.user.userEmail! == testEmail)
            case .failure(let error):
                XCTFail("Login failed: \(error)")
            }
        }
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func test03Logout() {
        let tpKit = getTpKitSingleton()
        let expectation = self.expectation(description: "logIn/logOut completes")
        ensureLogin() {
            session in
            tpKit.logOut() {
                result in
                expectation.fulfill()
                switch result {
                case .success:
                    break
                case .failure(let error):
                    XCTFail("LogOut failed: \(error)")
                    break
                }
            }
        }
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    
    func test04LoginWithSavedSession() {
        let tpKit = getTpKitSingleton()
        let expectation = self.expectation(description: "login with saved session completed")
        ensureLogin() {
            session in
            let session = tpKit.currentSession!
            tpKit.clearSession() // non-public test hook to clear state
            let result = tpKit.logIn(with: session)
            if case .failure = result {
                XCTFail("Login with saved session failed!")
            } else {
                tpKit.refreshSession() {
                    result in
                    expectation.fulfill()
                    switch result {
                    case .success:
                        XCTAssert(tpKit.isLoggedIn() == true)
                    case .failure(let error):
                        XCTFail("Failed to refresh token, error: \(error)")
                    }
                }
            }
        }
        waitForExpectations(timeout: 20.0, handler: nil)
    }
    
    func test05RefreshWithExpiredToken() {
        let tpKit = getTpKitSingleton()
        let expectation = self.expectation(description: "Login, logout, and refresh completed")
        ensureLogin() {
            session in
            tpKit.logOut() {
                result in
                switch result {
                case .success:
                    // now login with just saved session credentials...
                    let result = tpKit.logIn(with: session)
                    if case .failure = result {
                        XCTFail("Login with saved session failed!")
                    } else {
                        // and attempt to refresh auth token...
                        tpKit.refreshSession() {
                            result in
                            expectation.fulfill()
                            switch result {
                            case .success:
                                XCTFail("Refresh of expired token incorrectly succeeded!")
                            case .failure(let error):
                                if case .unauthorized = error {
                                    NSLog("Correctly failed to refresh token, error: \(error)")
                                    XCTAssert(tpKit.currentSession == nil)
                                } else {
                                    XCTFail("refresh correctly failed, but with unexpected error: \(error)")
                                }
                             }
                        }
                    }
                 case .failure(let error):
                    XCTFail("LogOut failed: \(error)")
                }
            }
        }
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test10LoginErrorNotReachable() {
        let expectation = self.expectation(description: "Login call fails with offline error")
        let tpKit = getTpKitSingleton()
        self.configureOffline(true)
        if tpKit.isLoggedIn() {
            tpKit.logOut() { _ in }
        }
        tpKit.logIn(with: "badUserEmail@bad.com", password: testPassword, serverHost: testServerHost) {
            result in
            expectation.fulfill()
            // be sure to restore reachability...
            self.configureOffline(false)
            self.checkForOfflineResult(result, fetchType: "login")
        }
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 5.0, handler: nil)
    }

}
