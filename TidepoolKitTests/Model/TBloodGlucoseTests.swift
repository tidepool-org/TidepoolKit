//
//  TBloodGlucoseTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 11/5/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TBloodGlucoseUnitsTests: XCTestCase {
    func testUnits() {
        XCTAssertEqual(TBloodGlucose.Units.milligramsPerDeciliter.rawValue, "mg/dL")
        XCTAssertEqual(TBloodGlucose.Units.millimolesPerLiter.rawValue, "mmol/L")
    }
}

class TBloodGlucoseTargetTests: XCTestCase {
    static let target = TBloodGlucose.Target(target: 1.23)
    static let targetJSONDictionary: [String: Any] = [
        "target": 1.23
    ]
    
    func testInitializerWithTarget() {
        let target = TBloodGlucose.Target(target: 1.23)
        XCTAssertEqual(target.target, 1.23)
    }
    
    func testInitializerWithTargetAndRange() {
        let target = TBloodGlucose.Target(target: 1.23, range: 2.34)
        XCTAssertEqual(target.target, 1.23)
        XCTAssertEqual(target.range, 2.34)
    }
    
    func testInitializerWithTargetAndHigh() {
        let target = TBloodGlucose.Target(target: 1.23, high: 2.34)
        XCTAssertEqual(target.target, 1.23)
        XCTAssertEqual(target.high, 2.34)
    }
    
    func testInitializerWithLowAndHigh() {
        let target = TBloodGlucose.Target(low: 1.23, high: 2.34)
        XCTAssertEqual(target.low, 1.23)
        XCTAssertEqual(target.high, 2.34)
    }
    
    func testCodableAsJSONWithTarget() {
        let target = TBloodGlucose.Target(target: 1.23)
        XCTAssertCodableAsJSON(target, ["target": 1.23])
    }
    
    func testCodableAsJSONWithTargetAndRange() {
        let target = TBloodGlucose.Target(target: 1.23, range: 2.34)
        XCTAssertCodableAsJSON(target, ["target": 1.23, "range": 2.34])
    }
    
    func testCodableAsJSONWithTargetAndHigh() {
        let target = TBloodGlucose.Target(target: 1.23, high: 2.34)
        XCTAssertCodableAsJSON(target, ["target": 1.23, "high": 2.34])
    }
    
    func testCodableAsJSONWithLowAndHigh() {
        let target = TBloodGlucose.Target(low: 1.23, high: 2.34)
        XCTAssertCodableAsJSON(target, ["low": 1.23, "high": 2.34])
    }
}

class TBloodGlucoseStartTargetTests: XCTestCase {
    static let startTarget = TBloodGlucose.StartTarget(start: 12345678, target: 1.23)
    static let startTargetJSONDictionary: [String: Any] = [
        "start": 12345678,
        "target": 1.23
    ]

    func testInitializerWithTarget() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, target: 1.23)
        XCTAssertEqual(startTarget.start, 12345678)
        XCTAssertEqual(startTarget.target, 1.23)
    }

    func testInitializerWithTargetAndRange() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, target: 1.23, range: 2.34)
        XCTAssertEqual(startTarget.start, 12345678)
        XCTAssertEqual(startTarget.target, 1.23)
        XCTAssertEqual(startTarget.range, 2.34)
    }

    func testInitializerWithTargetAndHigh() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, target: 1.23, high: 2.34)
        XCTAssertEqual(startTarget.start, 12345678)
        XCTAssertEqual(startTarget.target, 1.23)
        XCTAssertEqual(startTarget.high, 2.34)
    }

    func testInitializerWithLowAndHigh() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, low: 1.23, high: 2.34)
        XCTAssertEqual(startTarget.start, 12345678)
        XCTAssertEqual(startTarget.low, 1.23)
        XCTAssertEqual(startTarget.high, 2.34)
    }

    func testCodableAsJSONWithTarget() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, target: 1.23)
        XCTAssertCodableAsJSON(startTarget, ["start": 12345678, "target": 1.23])
    }

    func testCodableAsJSONWithTargetAndRange() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, target: 1.23, range: 2.34)
        XCTAssertCodableAsJSON(startTarget, ["start": 12345678, "target": 1.23, "range": 2.34])
    }

    func testCodableAsJSONWithTargetAndHigh() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, target: 1.23, high: 2.34)
        XCTAssertCodableAsJSON(startTarget, ["start": 12345678, "target": 1.23, "high": 2.34])
    }

    func testCodableAsJSONWithLowAndHigh() {
        let startTarget = TBloodGlucose.StartTarget(start: 12345678, low: 1.23, high: 2.34)
        XCTAssertCodableAsJSON(startTarget, ["start": 12345678, "low": 1.23, "high": 2.34])
    }
}
