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

import XCTest
@testable import TidepoolKit


class TPKitTests00Login: TPKitTestsBase {

    func test01LoginBadUser() {
        let expectation = self.expectation(description: "Login fails")
        let tpKit = getTpKitSingleton()
        if tpKit.isLoggedIn() {
            tpKit.logOut()
        }
        tpKit.logIn("badUserEmail@bad.com", password: testPassword, server: testServer) {
            result in
            switch result {
            case .success:
                XCTFail("Expected login to fail with bad user email!")
            case .failure(let error):
                NSLog("login with bad user returned: \(error)")
                switch error {
                case .unauthorized:
                    expectation.fulfill()
                default:
                    XCTFail("expected unauthorized error!")
                }
            }
        }
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test02Login() {
        let expectation = self.expectation(description: "Login successful")
        let tpKit = getTpKitSingleton()
        if tpKit.isLoggedIn() {
            tpKit.logOut()
        }
        tpKit.logIn(testEmail, password: testPassword, server: testServer) {
            result in
            switch result {
            case .success(let session):
                XCTAssert(session.user.userName != nil)
                XCTAssert(session.user.userName! == testEmail)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Login failed: \(error)")
            }
        }
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func test03Logout() {
        let tpKit = getTpKitSingleton()
        if !tpKit.isLoggedIn() {
            let expectation = self.expectation(description: "Login successful")
            tpKit.logIn(testEmail, password: testPassword, server: testServer) {
                result in
                expectation.fulfill()
                switch result {
                case .success:
                    tpKit.logOut()
                case .failure(let error):
                    XCTFail("Login failed: \(error)")
                }
            }
        } else {
            tpKit.logOut()
            return
        }
        waitForExpectations(timeout: 20.0, handler: nil)
    }
    
    func test04LoginWithSavedSession() {
        let tpKit = getTpKitSingleton()
        if !tpKit.isLoggedIn() {
            let expectation = self.expectation(description: "Login successful")
            tpKit.logIn(testEmail, password: testPassword, server: testServer) {
                result in
                expectation.fulfill()
                switch result {
                case .success (let session):
                    tpKit.logOut()
                    let result = tpKit.logIn(session)
                    if case .failure = result {
                        XCTFail("Login with saved session failed!")
                    }
                case .failure(let error):
                    XCTFail("Initial login failed: \(error)")
                }
            }
        } else {
            tpKit.logOut()
            return
        }
        waitForExpectations(timeout: 20.0, handler: nil)
    }

}
