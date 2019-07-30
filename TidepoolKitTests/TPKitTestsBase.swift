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

/// TODO: Set up a new test password?
var userid: String = ""
//var testEmail: String = "ethan+urchintests@tidepool.org"
//var testPassword: String = "urchintests"
//var testService: String = "Development"
var testEmail: String = "larry+kittest@tidepool.org"
var testPassword: String = "larry+kittest"
var testService: String = "Staging"

class TPKitTestsBase: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
    }
    
    func ensureLogin(completion: @escaping (Result<TPUser, TidepoolKitError>) -> Void) {
        let tpKit = TidepoolKit.sharedInstance
        tpKit.switchToServer(testService)
        guard let user = tpKit.loggedInUser() else {
            tpKit.logIn(testEmail, password: testPassword) {
                result in
                switch result {
                case .success:
                    completion(result)
                case .failure(let error):
                    XCTFail("Login failed: \(error)")
                }
            }
            return
        }
        completion(.success(user))
    }

}
