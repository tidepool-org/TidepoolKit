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
            tpKit.logOut()
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
            tpKit.logOut()
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
        if !tpKit.isLoggedIn() {
            let expectation = self.expectation(description: "Login successful")
            tpKit.logIn(with: testEmail, password: testPassword, server: testServer) {
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
            tpKit.logIn(with: testEmail, password: testPassword, server: testServer) {
                result in
                expectation.fulfill()
                switch result {
                case .success (let session):
                    tpKit.logOut()
                    let result = tpKit.logIn(with: session)
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
