//
//  TDatumSelectorTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 11/11/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TDatumSelectorTests: XCTestCase {
    static let selector = TDatumSelector(id: "abcdefghij", origin: TDatumSelectorOriginTests.origin)
    static let selectorJSONDictionary: [String: Any] = [
        "id": "abcdefghij",
        "origin": TDatumSelectorOriginTests.originJSONDictionary
    ]
    
    func testInitializer() {
        let selector = TDatumSelectorTests.selector
        XCTAssertEqual(selector.id, "abcdefghij")
        XCTAssertEqual(selector.origin, TDatumSelectorOriginTests.origin)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDatumSelectorTests.selector, TDatumSelectorTests.selectorJSONDictionary)
    }
}

class TDatumSelectorOriginTests: XCTestCase {
    static let origin = TDatumSelector.Origin(id: "1234567890")
    static let originJSONDictionary: [String: Any] = [
        "id": "1234567890",
    ]
    
    func testInitializer() {
        let origin = TDatumSelectorOriginTests.origin
        XCTAssertEqual(origin.id, "1234567890")
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDatumSelectorOriginTests.origin, TDatumSelectorOriginTests.originJSONDictionary)
    }
}
