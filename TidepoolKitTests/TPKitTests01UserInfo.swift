//
//  TPKitTests01UserInfo.swift
//  TidepoolKitTests
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPKitTests01UserInfo: TPKitTestsBase {
    
    func test01UserProfileFetch() {
        let expectation = self.expectation(description: "user profile fetch completed")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user profile...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            tpKit.getProfileInfo(for: session.user, with: session) {
                result in
                expectation.fulfill()
                switch result {
                case .success(let tpUserProfile):
                    NSLog("TPUserProfile fetch succeeded: \(tpUserProfile)")
                case .failure(let error):
                    XCTFail("profile fetch failed! Error: \(error)")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
        
    }
    
    func test01aUserProfileOfflineFetch() {
        let expectation = self.expectation(description: "user profile fetch failed with offline")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user profile...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            self.configureOffline(true)
            tpKit.getProfileInfo(for: session.user, with: session) {
                result in
                expectation.fulfill()
                // be sure to restore reachability...
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "user profile fetch")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
        
    }

    
    func test02UserSettingsFetch() {
        let expectation = self.expectation(description: "user settings fetch completed")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user settings...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            tpKit.getSettingsInfo(for: session.user, with: session) {
                result in
                expectation.fulfill()
                switch result {
                case .success(let tpUserSettings):
                    if let settings = tpUserSettings {
                        NSLog("TPUserSettings fetch succeeded: \(settings)")
                    } else {
                        NSLog("TPUserSettings fetch found no settings for this user!")
                    }
                case .failure(let error):
                    XCTFail("settings fetch failed! Error: \(error)")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test02aUserSettingsOfflineFetch() {
        let expectation = self.expectation(description: "user settings fetch failed with offline")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user settings...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            self.configureOffline(true)
            tpKit.getSettingsInfo(for: session.user, with: session) {
                result in
                expectation.fulfill()
                // be sure to restore reachability...
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "user settings fetch")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test03AccessUsersFetch() {
        let expectation = self.expectation(description: "access users fetch, and fetch of one user profile complete")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user settings...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            tpKit.getAccessUsers(for: session.user, with: session) {
                result in
                switch result {
                case .success(let accessUsers):
                    NSLog("access users fetch succeeded: \n\(accessUsers)")
                    // should have returned at least the root object... try fetching that profile (same as logged in user). TODO: try fetching all profiles...
                    XCTAssert(!accessUsers.isEmpty)
                    tpKit.getProfileInfo(for: accessUsers.last!, with: session) {
                        result in
                        expectation.fulfill()
                        switch result {
                        case .success(let tpUserProfile):
                            NSLog("profile fetch succeeded: \(tpUserProfile)")
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

    func test03aAccessUsersOfflineFetch() {
        let expectation = self.expectation(description: "access users fetch failed with offline")
        let tpKit = getTpKitSingleton()
        // Log in if necessary, and then try fetching user settings...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            self.configureOffline(true)
            tpKit.getAccessUsers(for: session.user, with: session) {
                result in
                expectation.fulfill()
                // be sure to restore reachability...
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "access users fetch")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    
}
