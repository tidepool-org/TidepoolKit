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
        let tpKit = TidepoolKit.sharedInstance
        if tpKit.isLoggedIn() {
            tpKit.logOut()
        }
        tpKit.switchToServer(testService)
        tpKit.logIn("badUserEmail@bad.com", password: testPassword) {
            result in
            switch result {
            case .success:
                XCTFail("Expected login to fail with bad user email!")
            case .failure(let error):
                NSLog("login with bad user returned: \(error)")
                XCTAssert(error == .unauthorized)
                expectation.fulfill()
            }
        }
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 5.0, handler: nil)
    }

    func test02Login() {
        let expectation = self.expectation(description: "Login successful")
        let tpKit = TidepoolKit.sharedInstance
        if tpKit.isLoggedIn() {
            tpKit.logOut()
        }
        tpKit.switchToServer(testService)
        tpKit.logIn(testEmail, password: testPassword) {
            result in
            switch result {
            case .success(let user):
                XCTAssert(user.userName != nil)
                XCTAssert(user.userName! == testEmail)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Login failed: \(error)")
            }
        }
        // Wait 5.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 5.0, handler: nil)
    }
    
    func test03Logout() {
        let tpKit = TidepoolKit.sharedInstance
        if !tpKit.isLoggedIn() {
            let expectation = self.expectation(description: "Login successful")
            tpKit.logIn(testEmail, password: testPassword) {
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
    
}
