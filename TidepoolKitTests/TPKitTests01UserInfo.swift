//
//  TPKitTests01UserInfo.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
@testable import TidepoolKit

class TPKitTests01UserInfo: TPKitTestsBase {

    func test01UserProfileFetch() {
        let expectation = self.expectation(description: "Profile fetch successful")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user profile...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            tpKit.getProfileInfo(for: session.user) {
                result in
                switch result {
                case .success(let tpUserProfile):
                    NSLog("TPUserProfile fetch succeeded: \(tpUserProfile)")
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("profile fetch failed! Error: \(error)")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
        
    }
    
    func test02UserSettingsFetch() {
        let expectation = self.expectation(description: "User settings fetch successful")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user settings...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            tpKit.getSettingsInfo(for: session.user) {
                result in
                switch result {
                case .success(let tpUserSettings):
                    if let settings = tpUserSettings {
                        NSLog("TPUserSettings fetch succeeded: \(settings)")
                    } else {
                        NSLog("TPUserSettings fetch found no settings for this user!")
                    }
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("settings fetch failed! Error: \(error)")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
        
    }

    func test03AccessUsersFetch() {
        let expectation = self.expectation(description: "Access users fetch successful")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user settings...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            tpKit.getAccessUsers(for: session.user) {
                result in
                switch result {
                case .success(let accessUsers):
                    NSLog("access users fetch succeeded: \n\(accessUsers)")
                    // should have returned at least the root object... try fetching that profile (same as logged in user). TODO: try fetching all profiles...
                    XCTAssert(!accessUsers.isEmpty)
                    tpKit.getProfileInfo(for: accessUsers.last!) {
                        result in
                        switch result {
                        case .success(let tpUserProfile):
                            NSLog("profile fetch succeeded: \(tpUserProfile)")
                            expectation.fulfill()
                        case .failure(let error):
                            XCTFail("profile fetch failed! Error: \(error)")
                        }
                    }
                case .failure(let error):
                    XCTFail("access users fetch failed! Error: \(error)")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
        
    }

    
}
