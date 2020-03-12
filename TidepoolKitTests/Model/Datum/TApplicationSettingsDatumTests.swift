//
//  TApplicationSettingsDatumTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 3/7/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TApplicationSettingsDatumTests: XCTestCase {
    static let applicationSettings = TApplicationSettingsDatum(time: Date.test, name: "Acme Application", version: "1.2.3")
    static let applicationSettingsJSONDictionary: [String: Any] = [
        "type": "applicationSettings",
        "time": Date.testJSONString,
        "name": "Acme Application",
        "version": "1.2.3",
    ]

    func testInitializer() {
        let applicationSettings = TApplicationSettingsDatumTests.applicationSettings
        XCTAssertEqual(applicationSettings.name, "Acme Application")
        XCTAssertEqual(applicationSettings.version, "1.2.3")
    }

    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TApplicationSettingsDatumTests.applicationSettings, TApplicationSettingsDatumTests.applicationSettingsJSONDictionary)
    }
}

extension TApplicationSettingsDatum {
    func isEqual(to other: TApplicationSettingsDatum) -> Bool {
        return super.isEqual(to: other) && self.name == other.name && self.version == other.version
    }
}
