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
        let expectation = self.expectation(description: "Login fails")
        let tpKit = getTpKitSingleton()
        if tpKit.isLoggedIn() {
            tpKit.logOut() { _ in }
        }
        tpKit.logIn(with: "badUserEmail@bad.com", password: testPassword, server: testServer) {
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
            tpKit.logOut() { _ in }
        }
        tpKit.logIn(with: testEmail, password: testPassword, server: testServer) {
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
        let expectation = self.expectation(description: "logIn/logOut successful")
        func doLogOut() {
            tpKit.logOut() {
                result in
                switch result {
                case .success:
                    expectation.fulfill()
                    break
                case .failure(let error):
                    XCTFail("LogOut failed: \(error)")
                    break
                }
            }
        }
        if !tpKit.isLoggedIn() {
            tpKit.logIn(with: testEmail, password: testPassword, server: testServer) {
                result in
                switch result {
                case .success:
                     doLogOut()
                case .failure(let error):
                    XCTFail("LogIn failed: \(error)")
                }
            }
        } else {
            doLogOut()
        }
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    
    func test04LoginWithSavedSession() {
        let tpKit = getTpKitSingleton()
        let expectation = self.expectation(description: "Login with saved session successful")
        ensureLogin() {
            session in
            let session = tpKit.currentSession!
            tpKit.clearSession()
            let result = tpKit.logIn(with: session)
            if case .failure = result {
                XCTFail("Login with saved session failed!")
            } else {
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 20.0, handler: nil)
    }

}
