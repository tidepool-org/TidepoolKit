//
//  TSessionTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 3/3/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TSessionTests: XCTestCase {
    static let session = TSession(environment: TEnvironmentTests.environment,
                                  authenticationToken: "test-authentication-token",
                                  userId: "1234567890",
                                  trace: "test-trace")
    static let sessionJSONDictionary: [String: Any] = [
        "environment": TEnvironmentTests.environmentJSONDictionary,
        "authenticationToken": "test-authentication-token",
        "userId": "1234567890",
        "trace": "test-trace"
    ]

    func testInitializer() {
        let session = TSessionTests.session
        XCTAssertEqual(session.environment, TEnvironmentTests.environment)
        XCTAssertEqual(session.authenticationToken, "test-authentication-token")
        XCTAssertEqual(session.userId, "1234567890")
        XCTAssertEqual(session.trace, "test-trace")
    }

    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TSessionTests.session, TSessionTests.sessionJSONDictionary)
    }
}
