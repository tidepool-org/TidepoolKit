//
//  TAutomatedBasalDatumTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 11/8/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TAutomatedBasalDatumTests: XCTestCase {
    static let automatedBasal = TAutomatedBasalDatum(time: Date.test,
                                                     duration: 123.456,
                                                     expectedDuration: 234.567,
                                                     rate: 1.23,
                                                     scheduleName: "One",
                                                     insulinFormulation: TInsulinDatumFormulationTests.formulation)
    static let automatedBasalJSONDictionary: [String: Any] = [
        "type": "basal",
        "deliveryType": "automated",
        "time": Date.testJSONString,
        "duration": 123456,
        "expectedDuration": 234567,
        "rate": 1.23,
        "scheduleName": "One",
        "insulinFormulation": TInsulinDatumFormulationTests.formulationJSONDictionary
    ]
    
    func testInitializer() {
        let automatedBasal = TAutomatedBasalDatumTests.automatedBasal
        XCTAssertEqual(automatedBasal.duration, 123.456)
        XCTAssertEqual(automatedBasal.expectedDuration, 234.567)
        XCTAssertEqual(automatedBasal.rate, 1.23)
        XCTAssertEqual(automatedBasal.scheduleName, "One")
        XCTAssertEqual(automatedBasal.insulinFormulation, TInsulinDatumFormulationTests.formulation)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TAutomatedBasalDatumTests.automatedBasal, TAutomatedBasalDatumTests.automatedBasalJSONDictionary)
    }
}

class TAutomatedBasalDatumSuppressedTests: XCTestCase {
    static let suppressed = TAutomatedBasalDatum.Suppressed(rate: 2.34,
                                                            scheduleName: "Two",
                                                            insulinFormulation: TInsulinDatumFormulationTests.formulation,
                                                            annotations: [TDictionary(["a": "b", "c": 0]), TDictionary(["alpha": "bravo"])])
    static let suppressedJSONDictionary: [String: Any] = [
        "type": "basal",
        "deliveryType": "automated",
        "rate": 2.34,
        "scheduleName": "Two",
        "insulinFormulation": TInsulinDatumFormulationTests.formulationJSONDictionary,
        "annotations": [["a": "b", "c": 0], ["alpha": "bravo"]]
    ]
    
    func testInitializer() {
        let suppressed = TAutomatedBasalDatumSuppressedTests.suppressed
        XCTAssertEqual(suppressed.type, .basal)
        XCTAssertEqual(suppressed.deliveryType, .automated)
        XCTAssertEqual(suppressed.rate, 2.34)
        XCTAssertEqual(suppressed.scheduleName, "Two")
        XCTAssertEqual(suppressed.insulinFormulation, TInsulinDatumFormulationTests.formulation)
        XCTAssertEqual(suppressed.annotations, [TDictionary(["a": "b", "c": 0]), TDictionary(["alpha": "bravo"])])
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TAutomatedBasalDatumSuppressedTests.suppressed, TAutomatedBasalDatumSuppressedTests.suppressedJSONDictionary)
    }
}

extension TAutomatedBasalDatum {
    func isEqual(to other: TAutomatedBasalDatum) -> Bool {
        return super.isEqual(to: other) &&
            self.rate == other.rate &&
            self.scheduleName == other.scheduleName &&
            self.insulinFormulation == other.insulinFormulation
    }
}

extension TAutomatedBasalDatum.Suppressed {
    func isEqual(to other: TAutomatedBasalDatum.Suppressed) -> Bool {
        return super.isEqual(to: other) &&
            self.rate == other.rate &&
            self.scheduleName == other.scheduleName
    }
}
