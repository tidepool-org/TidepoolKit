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
                                                     alerts: ["Red Alert", "Yellow Alert"],
                                                     insulinOnBoard: TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoard,
                                                     carbohydratesOnBoard: TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoard,
                                                     bloodGlucoseTargetRangeSchedule: [TBloodGlucoseStartTargetTests.startTarget,
                                                                                       TBloodGlucoseStartTargetTests.startTarget],
                                                     bloodGlucoseForecast: [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast,
                                                                            TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast],
                                                     recommendedBasal: TDosingDecisionDatumRecommendedBasalTests.recommendedBasal,
                                                     recommendedBolus: TDosingDecisionDatumRecommendedBolusTests.recommendedBolus,
                                                     units: TDosingDecisionDatumUnitsTests.units)
    static let dosingDecisionJSONDictionary: [String: Any] = [
        "type": "dosingDecision",
        "time": Date.testJSONString,
        "alerts": ["Red Alert", "Yellow Alert"],
        "insulinOnBoard": TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoardJSONDictionary,
        "carbohydratesOnBoard": TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoardJSONDictionary,
        "bloodGlucoseTargetRangeSchedule": [TBloodGlucoseStartTargetTests.startTargetJSONDictionary,
                                            TBloodGlucoseStartTargetTests.startTargetJSONDictionary],
        "bloodGlucoseForecast": [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecastJSONDictionary,
                                 TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecastJSONDictionary],
        "recommendedBasal": TDosingDecisionDatumRecommendedBasalTests.recommendedBasalJSONDictionary,
        "recommendedBolus": TDosingDecisionDatumRecommendedBolusTests.recommendedBolusJSONDictionary,
        "units": TDosingDecisionDatumUnitsTests.unitsJSONDictionary
    ]
    
    func testInitializer() {
        let dosingDecision = TDosingDecisionDatumTests.dosingDecision
        XCTAssertEqual(dosingDecision.alerts, ["Red Alert", "Yellow Alert"])
        XCTAssertEqual(dosingDecision.insulinOnBoard, TDosingDecisionDatumInsulinOnBoardTests.insulinOnBoard)
        XCTAssertEqual(dosingDecision.carbohydratesOnBoard, TDosingDecisionDatumCarbohydratesOnBoardTests.carbohydratesOnBoard)
        XCTAssertEqual(dosingDecision.bloodGlucoseTargetRangeSchedule, [TBloodGlucoseStartTargetTests.startTarget,
                                                                        TBloodGlucoseStartTargetTests.startTarget])
        XCTAssertEqual(dosingDecision.bloodGlucoseForecast, [TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast,
                                                             TDosingDecisionDatumBloodGlucoseForecastTests.bloodGlucoseForecast])
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
    static let recommendedBasal = TDosingDecisionDatum.RecommendedBasal(rate: 1.23, duration: 1800000)
    static let recommendedBasalJSONDictionary: [String: Any] = [
        "rate": 1.23,
        "duration": 1800000
    ]
    
    func testInitializer() {
        let recommendedBasal = TDosingDecisionDatumRecommendedBasalTests.recommendedBasal
        XCTAssertEqual(recommendedBasal.rate, 1.23)
        XCTAssertEqual(recommendedBasal.duration, 1800000)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TDosingDecisionDatumRecommendedBasalTests.recommendedBasal, TDosingDecisionDatumRecommendedBasalTests.recommendedBasalJSONDictionary)
    }
}

class TDosingDecisionDatumRecommendedBolusTests: XCTestCase {
    static let recommendedBolus = TDosingDecisionDatum.RecommendedBolus(amount: 1.23)
    static let recommendedBolusJSONDictionary: [String: Any] = [
        "amount": 1.23
    ]
    
    func testInitializer() {
        let recommendedBolus = TDosingDecisionDatumRecommendedBolusTests.recommendedBolus
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
            self.alerts == other.alerts &&
            self.insulinOnBoard == other.insulinOnBoard &&
            self.carbohydratesOnBoard == other.carbohydratesOnBoard &&
            self.bloodGlucoseTargetRangeSchedule == other.bloodGlucoseTargetRangeSchedule &&
            self.bloodGlucoseForecast == other.bloodGlucoseForecast &&
            self.recommendedBasal == other.recommendedBasal &&
            self.recommendedBolus == other.recommendedBolus &&
            self.units == other.units
    }
}
