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

class TPKitTests01UserInfo: TPKitTestsBase {

    func test01UserProfileFetch() {
        let expectation = self.expectation(description: "Profile fetch successful")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user profile...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            tpKit.getUserProfileInfo(session.user) {
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
            tpKit.getUserSettingsInfo(session.user) {
                result in
                switch result {
                case .success(let tpUserSettings):
                    NSLog("TPUserSettings fetch succeeded: \n\(tpUserSettings)")
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
            tpKit.getAccessUsers(session.user) {
                result in
                switch result {
                case .success(let accessUsers):
                    NSLog("access users fetch succeeded: \n\(accessUsers)")
                    // should have returned at least the root object... try fetching that profile (same as logged in user). TODO: try fetching all profiles...
                    XCTAssert(!accessUsers.userIds.isEmpty)
                    tpKit.getUserProfileInfo(TPUser(accessUsers.userIds.first!)) {
                        result in
                        switch result {
                        case .success(let tpUserProfile):
                            NSLog("profile fetch succeeded: \n\(tpUserProfile)")
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
