//
//  TDosingDecisionDatumTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 3/6/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TDosingDecisionDatumTests: XCTestCase {
    static let dosingDecision = TDosingDecisionDatum(time: Date.test,
                                                     errors: ["Red Alert", "Yellow Alert"],
                                                     insulinOnBoard: TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoard,
                                                     carbohydratesOnBoard: TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoard,
                                                     bloodGlucoseTargetSchedule: [TBloodGlucoseStartTargetTests.startTarget,
                                                                                  TBloodGlucoseStartTargetTests.startTarget],
                                                     bloodGlucoseForecast: [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast,
                                                                            TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast],
                                                     bloodGlucoseForecastIncludingPendingInsulin: [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast],
                                                     recommendedBasal: TDosingDecisionDatumRecommendedBasalTests.recommendedBasal,
                                                     recommendedBolus: TDosingDecisionDatumRecommendedBolusTests.recommendedBolus,
                                                     units: TDosingDecisionDatumUnitsTests.units)
    static let dosingDecisionJSONDictionary: [String: Any] = [
        "type": "dosingDecision",
        "time": Date.testJSONString,
        "errors": ["Red Alert", "Yellow Alert"],
        "insulinOnBoard": TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoardJSONDictionary,
        "carbohydratesOnBoard": TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoardJSONDictionary,
        "bloodGlucoseTargetSchedule": [TBloodGlucoseStartTargetTests.startTargetJSONDictionary,
                                       TBloodGlucoseStartTargetTests.startTargetJSONDictionary],
        "bloodGlucoseForecast": [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecastJSONDictionary,
                                 TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecastJSONDictionary],
        "bloodGlucoseForecastIncludingPendingInsulin": [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecastJSONDictionary],
        "recommendedBasal": TDosingDecisionDatumRecommendedBasalTests.recommendedBasalJSONDictionary,
        "recommendedBolus": TDosingDecisionDatumRecommendedBolusTests.recommendedBolusJSONDictionary,
        "units": TDosingDecisionDatumUnitsTests.unitsJSONDictionary
    ]
    
    func testInitializer() {
        let dosingDecision = TDosingDecisionDatumTests.dosingDecision
        XCTAssertEqual(dosingDecision.errors, ["Red Alert", "Yellow Alert"])
        XCTAssertEqual(dosingDecision.insulinOnBoard, TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoard)
        XCTAssertEqual(dosingDecision.carbohydratesOnBoard, TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoard)
        XCTAssertEqual(dosingDecision.bloodGlucoseTargetSchedule, [TBloodGlucoseStartTargetTests.startTarget,
                                                                   TBloodGlucoseStartTargetTests.startTarget])
        XCTAssertEqual(dosingDecision.bloodGlucoseForecast, [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast,
                                                             TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast])
        XCTAssertEqual(dosingDecision.bloodGlucoseForecastIncludingPendingInsulin, [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast])
        XCTAssertEqual(dosingDecision.recommendedBasal, TDosingDecisionDatumRecommendedBasalTests.recommendedBasal)
        XCTAssertEqual(dosingDecision.recommendedBolus, TDosingDecisionDatumRecommendedBolusTests.recommendedBolus)
        XCTAssertEqual(dosingDecision.units, TDosingDecisionDatumUnitsTests.units)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumTests.dosingDecision, TDosingDecisionDatumTests.dosingDecisionJSONDictionary)
    }
}

class TDosingDecisionDatumInsulinOnBoardTests: XCTestCase {
    static let insulinOnBoard = TDosingDecisionDatum.InsulinOnBoard(startTime: Date.test, amount: 1.23)
    static let insulinOnBoardJSONDictionary: [String: Any] = [
        "startTime": Date.testJSONString,
        "amount": 1.23,
    ]
    
    func testInitializer() {
        let insulinOnBoard = TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoard
        XCTAssertEqual(insulinOnBoard.startTime, Date.test)
        XCTAssertEqual(insulinOnBoard.amount, 1.23)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoard, TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoardJSONDictionary)
    }
}

class TDosingDecisionDatumCarbohydratesOnBoardTests: XCTestCase {
    static let carbohydratesOnBoard = TDosingDecisionDatum.CarbohydratesOnBoard(startTime: Date.test, endTime: Date.test, amount: 1.23)
    static let carbohydratesOnBoardJSONDictionary: [String: Any] = [
        "startTime": Date.testJSONString,
        "endTime": Date.testJSONString,
        "amount": 1.23,
    ]
    
    func testInitializer() {
        let carbohydratesOnBoard = TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoard
        XCTAssertEqual(carbohydratesOnBoard.startTime, Date.test)
        XCTAssertEqual(carbohydratesOnBoard.endTime, Date.test)
        XCTAssertEqual(carbohydratesOnBoard.amount, 1.23)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoard, TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoardJSONDictionary)
    }
}

class TDosingDecisionDatumBloodGlucoseForecastTests: XCTestCase {
    static let bloodGlucoseForecast = TDosingDecisionDatum.BloodGlucoseForecast(time: Date.test, value: 1.23)
    static let bloodGlucoseForecastJSONDictionary: [String: Any] = [
        "time": Date.testJSONString,
        "value": 1.23,
    ]
    
    func testInitializer() {
        let bloodGlucoseForecast = TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast
        XCTAssertEqual(bloodGlucoseForecast.time, Date.test)
        XCTAssertEqual(bloodGlucoseForecast.value, 1.23)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast, TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecastJSONDictionary)
    }
}

class TDosingDecisionDatumRecommendedBasalTests: XCTestCase {
    static let recommendedBasal = TDosingDecisionDatum.RecommendedBasal(time: Date.test, rate: 1.23, duration: 1800)
    static let recommendedBasalJSONDictionary: [String: Any] = [
        "time": Date.testJSONString,
        "rate": 1.23,
        "duration": 1800
    ]
    
    func testInitializer() {
        let recommendedBasal = TDosingDecisionDatumRecommendedBasalTests.recommendedBasal
        XCTAssertEqual(recommendedBasal.time, Date.test)
        XCTAssertEqual(recommendedBasal.rate, 1.23)
        XCTAssertEqual(recommendedBasal.duration, 1800)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumRecommendedBasalTests.recommendedBasal, TDosingDecisionDatumRecommendedBasalTests.recommendedBasalJSONDictionary)
    }
}

class TDosingDecisionDatumRecommendedBolusTests: XCTestCase {
    static let recommendedBolus = TDosingDecisionDatum.RecommendedBolus(time: Date.test, amount: 1.23)
    static let recommendedBolusJSONDictionary: [String: Any] = [
        "time": Date.testJSONString,
        "amount": 1.23
    ]
    
    func testInitializer() {
        let recommendedBolus = TDosingDecisionDatumRecommendedBolusTests.recommendedBolus
        XCTAssertEqual(recommendedBolus.time, Date.test)
        XCTAssertEqual(recommendedBolus.amount, 1.23)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumRecommendedBolusTests.recommendedBolus, TDosingDecisionDatumRecommendedBolusTests.recommendedBolusJSONDictionary)
    }
}

class TDosingDecisionDatumUnitsTests: XCTestCase {
    static let units = TDosingDecisionDatum.Units(bloodGlucose: .milligramsPerDeciliter, carbohydrate: .grams, insulin: .units)
    static let unitsJSONDictionary: [String: Any] = [
        "bloodGlucose": "mg/dL",
        "carbohydrate": "grams",
        "insulin": "Units"
    ]
    
    func testInitializer() {
        let units = TDosingDecisionDatumUnitsTests.units
        XCTAssertEqual(units.bloodGlucose, .milligramsPerDeciliter)
        XCTAssertEqual(units.carbohydrate, .grams)
        XCTAssertEqual(units.insulin, .units)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumUnitsTests.units, TDosingDecisionDatumUnitsTests.unitsJSONDictionary)
    }
}

extension TDosingDecisionDatum {
    func isEqual(to other: TDosingDecisionDatum) -> Bool {
        return super.isEqual(to: other) &&
            self.errors == other.errors &&
            self.insulinOnBoard == other.insulinOnBoard &&
            self.carbohydratesOnBoard == other.carbohydratesOnBoard &&
            self.bloodGlucoseTargetSchedule == other.bloodGlucoseTargetSchedule &&
            self.bloodGlucoseForecast == other.bloodGlucoseForecast &&
            self.bloodGlucoseForecastIncludingPendingInsulin == other.bloodGlucoseForecastIncludingPendingInsulin &&
            self.recommendedBasal == other.recommendedBasal &&
            self.recommendedBolus == other.recommendedBolus &&
            self.units == other.units
    }
}
