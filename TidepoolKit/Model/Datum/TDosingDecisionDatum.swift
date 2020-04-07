//
//  TDosingDecisionDatum.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 3/6/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation

public class TDosingDecisionDatum: TDatum, Decodable {
    public typealias BloodGlucoseStartTarget = TBloodGlucose.StartTarget

    public var errors: [String]?
    public var insulinOnBoard: InsulinOnBoard?
    public var carbohydratesOnBoard: CarbohydratesOnBoard?
    public var bloodGlucoseTargetSchedule: [BloodGlucoseStartTarget]?
    public var bloodGlucoseForecast: [BloodGlucoseForecast]?
    public var bloodGlucoseForecastIncludingPendingInsulin: [BloodGlucoseForecast]?
    public var recommendedBasal: RecommendedBasal?
    public var recommendedBolus: RecommendedBolus?
    public var units: Units?

    public init(time: Date,
                errors: [String]? = nil,
                insulinOnBoard: InsulinOnBoard? = nil,
                carbohydratesOnBoard: CarbohydratesOnBoard? = nil,
                bloodGlucoseTargetSchedule: [BloodGlucoseStartTarget]? = nil,
                bloodGlucoseForecast: [BloodGlucoseForecast]? = nil,
                bloodGlucoseForecastIncludingPendingInsulin: [BloodGlucoseForecast]? = nil,
                recommendedBasal: RecommendedBasal? = nil,
                recommendedBolus: RecommendedBolus? = nil,
                units: Units) {
        self.errors = errors
        self.insulinOnBoard = insulinOnBoard
        self.carbohydratesOnBoard = carbohydratesOnBoard
        self.bloodGlucoseTargetSchedule = bloodGlucoseTargetSchedule
        self.bloodGlucoseForecast = bloodGlucoseForecast
        self.bloodGlucoseForecastIncludingPendingInsulin = bloodGlucoseForecastIncludingPendingInsulin
        self.recommendedBasal = recommendedBasal
        self.recommendedBolus = recommendedBolus
        self.units = units
        super.init(.dosingDecision, time: time)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.errors = try container.decodeIfPresent([String].self, forKey: .errors)
        self.insulinOnBoard = try container.decodeIfPresent(InsulinOnBoard.self, forKey: .insulinOnBoard)
        self.carbohydratesOnBoard = try container.decodeIfPresent(CarbohydratesOnBoard.self, forKey: .carbohydratesOnBoard)
        self.bloodGlucoseTargetSchedule = try container.decodeIfPresent([BloodGlucoseStartTarget].self, forKey: .bloodGlucoseTargetSchedule)
        self.bloodGlucoseForecast = try container.decodeIfPresent([BloodGlucoseForecast].self, forKey: .bloodGlucoseForecast)
        self.bloodGlucoseForecastIncludingPendingInsulin = try container.decodeIfPresent([BloodGlucoseForecast].self, forKey: .bloodGlucoseForecastIncludingPendingInsulin)
        self.recommendedBasal = try container.decodeIfPresent(RecommendedBasal.self, forKey: .recommendedBasal)
        self.recommendedBolus = try container.decodeIfPresent(RecommendedBolus.self, forKey: .recommendedBolus)
        self.units = try container.decodeIfPresent(Units.self, forKey: .units)
        try super.init(.dosingDecision, from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(errors, forKey: .errors)
        try container.encodeIfPresent(insulinOnBoard, forKey: .insulinOnBoard)
        try container.encodeIfPresent(carbohydratesOnBoard, forKey: .carbohydratesOnBoard)
        try container.encodeIfPresent(bloodGlucoseTargetSchedule, forKey: .bloodGlucoseTargetSchedule)
        try container.encodeIfPresent(bloodGlucoseForecast, forKey: .bloodGlucoseForecast)
        try container.encodeIfPresent(bloodGlucoseForecastIncludingPendingInsulin, forKey: .bloodGlucoseForecastIncludingPendingInsulin)
        try container.encodeIfPresent(recommendedBasal, forKey: .recommendedBasal)
        try container.encodeIfPresent(recommendedBolus, forKey: .recommendedBolus)
        try container.encodeIfPresent(units, forKey: .units)
        try super.encode(to: encoder)
    }

    public struct InsulinOnBoard: Codable, Equatable {
        public var startTime: Date?
        public var amount: Double?

        public init(startTime: Date? = nil, amount: Double) {
            self.startTime = startTime
            self.amount = amount
        }
    }

    public struct CarbohydratesOnBoard: Codable, Equatable {
        public var startTime: Date?
        public var endTime: Date?
        public var amount: Double?

        public init(startTime: Date? = nil, endTime: Date? = nil, amount: Double) {
            self.startTime = startTime
            self.endTime = endTime
            self.amount = amount
        }
    }

    public struct BloodGlucoseForecast: Codable, Equatable {
        public var time: Date?
        public var value: Double?

        public init(time: Date, value: Double) {
            self.time = time
            self.value = value
        }
    }

    public struct RecommendedBasal: Codable, Equatable {
        public var time: Date?
        public var rate: Double?
        public var duration: Int?

        public init(time: Date, rate: Double, duration: Int) {
            self.time = time
            self.rate = rate
            self.duration = duration
        }
    }

    public struct RecommendedBolus: Codable, Equatable {
        public var time: Date?
        public var amount: Double?

        public init(time: Date, amount: Double) {
            self.time = time
            self.amount = amount
        }
    }

    public struct Units: Codable, Equatable {
        public typealias BloodGlucoseUnits = TBloodGlucose.Units
        public typealias CarbohydrateUnits = TCarbohydrate.Units
        public typealias InsulinUnits = TInsulin.Units

        public var bloodGlucose: BloodGlucoseUnits?
        public var carbohydrate: CarbohydrateUnits?
        public var insulin: InsulinUnits?

        public init(bloodGlucose: BloodGlucoseUnits, carbohydrate: CarbohydrateUnits, insulin: InsulinUnits) {
            self.bloodGlucose = bloodGlucose
            self.carbohydrate = carbohydrate
            self.insulin = insulin
        }
    }

    private enum CodingKeys: String, CodingKey {
        case errors
        case insulinOnBoard
        case carbohydratesOnBoard
        case bloodGlucoseTargetSchedule
        case bloodGlucoseForecast
        case bloodGlucoseForecastIncludingPendingInsulin
        case recommendedBasal
        case recommendedBolus
        case units
    }
}
