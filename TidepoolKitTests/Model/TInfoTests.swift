//
//  TInfoTests.swift
//  TidepoolKitTests
//
//  Created by Rick Pasetto on 9/7/21.
//  Copyright © 2021 Tidepool Project. All rights reserved.
//

import XCTest
@testable import TidepoolKit

class TInfoTests: XCTestCase {
    let info = TInfo(versions: TInfo.TVersionInfo(loop: TInfo.TVersionInfo.TLoopVersionInfo(minimumSupported: "1.2.0", criticalUpdateNeeded: ["1.1.0"])))
    let infoJSONDictionary: [String: Any] = [
        "versions": [
            "loop": [
                "minimumSupported": "1.2.0",
                "criticalUpdateNeeded": [ "1.1.0" ]
            ]
        ]
    ]
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(info, infoJSONDictionary)
    }
    func testNeedsCriticalUpdate() {
        XCTAssertFalse(info.versions.loop!.needsCriticalUpdate(version: "1.2.0"))
        XCTAssertTrue(info.versions.loop!.needsCriticalUpdate(version: "1.1.0"))
    }
    func testNeedsSupportedUpdate() {
        XCTAssertFalse(info.versions.loop!.needsSupportedUpdate(version: "1.2.0"))
        XCTAssertFalse(info.versions.loop!.needsSupportedUpdate(version: "1.2.1"))
        XCTAssertFalse(info.versions.loop!.needsSupportedUpdate(version: "2.1.0"))
        XCTAssertTrue(info.versions.loop!.needsSupportedUpdate(version: "0.1.0"))
        XCTAssertTrue(info.versions.loop!.needsSupportedUpdate(version: "0.3.0"))
        XCTAssertTrue(info.versions.loop!.needsSupportedUpdate(version: "0.3.1"))
        XCTAssertTrue(info.versions.loop!.needsSupportedUpdate(version: "1.1.0"))
        XCTAssertTrue(info.versions.loop!.needsSupportedUpdate(version: "1.1.99"))
    }
}
