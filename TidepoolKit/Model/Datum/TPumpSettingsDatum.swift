//
//  TPumpSettingsDatum.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 11/1/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPumpSettingsDatum: TDatum, Decodable {
    public typealias BloodGlucoseTarget = TBloodGlucose.Target
    public typealias BloodGlucoseStartTarget = TBloodGlucose.StartTarget

    public enum InsulinModel: String, Codable {
        case fiasp
        case rapidAdult
        case rapidChild
    }

    public var activeScheduleName: String?
    public var basal: Basal?
    public var basalRateSchedule: [BasalRateStart]?
    public var basalRateSchedules: [String: [BasalRateStart]]?
    public var basalRateSchedulesTimezoneOffset: Int?
    public var bloodGlucoseTargetPreprandial: BloodGlucoseTarget?
    public var bloodGlucoseTargetSchedule: [BloodGlucoseStartTarget]?
    public var bloodGlucoseTargetSchedules: [String: [BloodGlucoseStartTarget]]?
    public var bloodGlucoseTargetSchedulesTimezoneOffset: Int?
    public var bolus: Bolus?
    public var carbohydrateRatioSchedule: [CarbohydrateRatioStart]?
    public var carbohydrateRatioSchedules: [String: [CarbohydrateRatioStart]]?
    public var carbohydrateRatioSchedulesTimezoneOffset: Int?
    public var display: Display?
    public var dosingEnabled: Bool?
    public var insulinModel: InsulinModel?
    public var insulinSensitivitySchedule: [InsulinSensitivityStart]?
    public var insulinSensitivitySchedules: [String: [InsulinSensitivityStart]]?
    public var insulinSensitivitySchedulesTimezoneOffset: Int?
    public var manufacturers: [String]?
    public var model: String?
    public var serialNumber: String?
    public var suspendThreshold: SuspendThreshold?
    public var units: Units?
    
    public init(time: Date,
                activeScheduleName: String? = nil,
                basal: Basal? = nil,
                basalRateSchedule: [BasalRateStart]? = nil,
                basalRateSchedules: [String: [BasalRateStart]]? = nil,
                basalRateSchedulesTimezoneOffset: Int? = nil,
                bloodGlucoseTargetPreprandial: BloodGlucoseTarget? = nil,
                bloodGlucoseTargetSchedule: [BloodGlucoseStartTarget]? = nil,
                bloodGlucoseTargetSchedules: [String: [BloodGlucoseStartTarget]]? = nil,
                bloodGlucoseTargetSchedulesTimezoneOffset: Int? = nil,
                bolus: Bolus? = nil,
                carbohydrateRatioSchedule: [CarbohydrateRatioStart]? = nil,
                carbohydrateRatioSchedules: [String: [CarbohydrateRatioStart]]? = nil,
                carbohydrateRatioSchedulesTimezoneOffset: Int? = nil,
                display: Display? = nil,
                dosingEnabled: Bool? = nil,
                insulinModel: InsulinModel? = nil,
                insulinSensitivitySchedule: [InsulinSensitivityStart]? = nil,
                insulinSensitivitySchedules: [String: [InsulinSensitivityStart]]? = nil,
                insulinSensitivitySchedulesTimezoneOffset: Int? = nil,
                manufacturers: [String]? = nil,
                model: String? = nil,
                serialNumber: String? = nil,
                suspendThreshold: SuspendThreshold? = nil,
                units: Units? = nil) {
        self.activeScheduleName = activeScheduleName
        self.basal = basal
        self.basalRateSchedule = basalRateSchedule
        self.basalRateSchedules = basalRateSchedules
        self.basalRateSchedulesTimezoneOffset = basalRateSchedulesTimezoneOffset
        self.bloodGlucoseTargetPreprandial = bloodGlucoseTargetPreprandial
        self.bloodGlucoseTargetSchedule = bloodGlucoseTargetSchedule
        self.bloodGlucoseTargetSchedules = bloodGlucoseTargetSchedules
        self.bloodGlucoseTargetSchedulesTimezoneOffset = bloodGlucoseTargetSchedulesTimezoneOffset
        self.bolus = bolus
        self.carbohydrateRatioSchedule = carbohydrateRatioSchedule
        self.carbohydrateRatioSchedules = carbohydrateRatioSchedules
        self.carbohydrateRatioSchedulesTimezoneOffset = carbohydrateRatioSchedulesTimezoneOffset
        self.display = display
        self.dosingEnabled = dosingEnabled
        self.insulinModel = insulinModel
        self.insulinSensitivitySchedule = insulinSensitivitySchedule
        self.insulinSensitivitySchedules = insulinSensitivitySchedules
        self.insulinSensitivitySchedulesTimezoneOffset = insulinSensitivitySchedulesTimezoneOffset
        self.manufacturers = manufacturers
        self.model = model
        self.serialNumber = serialNumber
        self.suspendThreshold = suspendThreshold
        self.units = units
        super.init(.pumpSettings, time: time)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.activeScheduleName = try container.decodeIfPresent(String.self, forKey: .activeScheduleName)
        self.basal = try container.decodeIfPresent(Basal.self, forKey: .basal)
        self.basalRateSchedule = try container.decodeIfPresent([BasalRateStart].self, forKey: .basalRateSchedule)
        self.basalRateSchedules = try container.decodeIfPresent([String: [BasalRateStart]].self, forKey: .basalRateSchedules)
        self.basalRateSchedulesTimezoneOffset = try container.decodeIfPresent(Int.self, forKey: .basalRateSchedulesTimezoneOffset)
        self.bloodGlucoseTargetPreprandial = try container.decodeIfPresent(BloodGlucoseTarget.self, forKey: .bloodGlucoseTargetPreprandial)
        self.bloodGlucoseTargetSchedule = try container.decodeIfPresent([BloodGlucoseStartTarget].self, forKey: .bloodGlucoseTargetSchedule)
        self.bloodGlucoseTargetSchedules = try container.decodeIfPresent([String: [BloodGlucoseStartTarget]].self, forKey: .bloodGlucoseTargetSchedules)
        self.bloodGlucoseTargetSchedulesTimezoneOffset = try container.decodeIfPresent(Int.self, forKey: .bloodGlucoseTargetSchedulesTimezoneOffset)
        self.bolus = try container.decodeIfPresent(Bolus.self, forKey: .bolus)
        self.carbohydrateRatioSchedule = try container.decodeIfPresent([CarbohydrateRatioStart].self, forKey: .carbohydrateRatioSchedule)
        self.carbohydrateRatioSchedules = try container.decodeIfPresent([String: [CarbohydrateRatioStart]].self, forKey: .carbohydrateRatioSchedules)
        self.carbohydrateRatioSchedulesTimezoneOffset = try container.decodeIfPresent(Int.self, forKey: .carbohydrateRatioSchedulesTimezoneOffset)
        self.display = try container.decodeIfPresent(Display.self, forKey: .display)
        self.dosingEnabled = try container.decodeIfPresent(Bool.self, forKey: .dosingEnabled)
        self.insulinModel = try container.decodeIfPresent(InsulinModel.self, forKey: .insulinModel)
        self.insulinSensitivitySchedule = try container.decodeIfPresent([InsulinSensitivityStart].self, forKey: .insulinSensitivitySchedule)
        self.insulinSensitivitySchedules = try container.decodeIfPresent([String: [InsulinSensitivityStart]].self, forKey: .insulinSensitivitySchedules)
        self.insulinSensitivitySchedulesTimezoneOffset = try container.decodeIfPresent(Int.self, forKey: .insulinSensitivitySchedulesTimezoneOffset)
        self.manufacturers = try container.decodeIfPresent([String].self, forKey: .manufacturers)
        self.model = try container.decodeIfPresent(String.self, forKey: .model)
        self.serialNumber = try container.decodeIfPresent(String.self, forKey: .serialNumber)
        self.suspendThreshold = try container.decodeIfPresent(SuspendThreshold.self, forKey: .suspendThreshold)
        self.units = try container.decodeIfPresent(Units.self, forKey: .units)
        try super.init(.pumpSettings, from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(activeScheduleName, forKey: .activeScheduleName)
        try container.encodeIfPresent(basal, forKey: .basal)
        try container.encodeIfPresent(basalRateSchedule, forKey: .basalRateSchedule)
        try container.encodeIfPresent(basalRateSchedules, forKey: .basalRateSchedules)
        try container.encodeIfPresent(basalRateSchedulesTimezoneOffset, forKey: .basalRateSchedulesTimezoneOffset)
        try container.encodeIfPresent(bloodGlucoseTargetPreprandial, forKey: .bloodGlucoseTargetPreprandial)
        try container.encodeIfPresent(bloodGlucoseTargetSchedule, forKey: .bloodGlucoseTargetSchedule)
        try container.encodeIfPresent(bloodGlucoseTargetSchedules, forKey: .bloodGlucoseTargetSchedules)
        try container.encodeIfPresent(bloodGlucoseTargetSchedulesTimezoneOffset, forKey: .bloodGlucoseTargetSchedulesTimezoneOffset)
        try container.encodeIfPresent(bolus, forKey: .bolus)
        try container.encodeIfPresent(carbohydrateRatioSchedule, forKey: .carbohydrateRatioSchedule)
        try container.encodeIfPresent(carbohydrateRatioSchedules, forKey: .carbohydrateRatioSchedules)
        try container.encodeIfPresent(carbohydrateRatioSchedulesTimezoneOffset, forKey: .carbohydrateRatioSchedulesTimezoneOffset)
        try container.encodeIfPresent(display, forKey: .display)
        try container.encodeIfPresent(dosingEnabled, forKey: .dosingEnabled)
        try container.encodeIfPresent(insulinModel, forKey: .insulinModel)
        try container.encodeIfPresent(insulinSensitivitySchedule, forKey: .insulinSensitivitySchedule)
        try container.encodeIfPresent(insulinSensitivitySchedules, forKey: .insulinSensitivitySchedules)
        try container.encodeIfPresent(insulinSensitivitySchedulesTimezoneOffset, forKey: .insulinSensitivitySchedulesTimezoneOffset)
        try container.encodeIfPresent(manufacturers, forKey: .manufacturers)
        try container.encodeIfPresent(model, forKey: .model)
        try container.encodeIfPresent(serialNumber, forKey: .serialNumber)
        try container.encodeIfPresent(suspendThreshold, forKey: .suspendThreshold)
        try container.encodeIfPresent(units, forKey: .units)
        try super.encode(to: encoder)
    }
    
    public struct Basal: Codable, Equatable {
        public var rateMaximum: RateMaximum?
        public var temporary: Temporary?
        
        public init(rateMaximum: RateMaximum? = nil, temporary: Temporary? = nil) {
            self.rateMaximum = rateMaximum
            self.temporary = temporary
        }
        
        public struct RateMaximum: Codable, Equatable {
            public enum Units: String, Codable {
                case unitsPerHour = "Units/hour"
            }
            
            public var value: Double?
            public var units: Units?
            
            public init(_ value: Double, _ units: Units = .unitsPerHour) {
                self.value = value
                self.units = units
            }
        }
        
        public struct Temporary: Codable, Equatable {
            public enum TemporaryType: String, Codable {
                case off
                case percent
                case unitsPerHour = "Units/hour"
            }
            
            public var type: TemporaryType?
            
            public init(_ type: TemporaryType) {
                self.type = type
            }
        }
    }
    
    public struct BasalRateStart: Codable, Equatable {
        public var start: Int?
        public var rate: Double?
        
        public init(start: Int, rate: Double) {
            self.start = start
            self.rate = rate
        }
    }

    public struct Bolus: Codable, Equatable {
        public var amountMaximum: AmountMaximum?
        public var calculator: Calculator?
        public var extended: Extended?
        
        public init(amountMaximum: AmountMaximum? = nil, calculator: Calculator? = nil, extended: Extended? = nil) {
            self.amountMaximum = amountMaximum
            self.calculator = calculator
            self.extended = extended
        }
        
        public struct AmountMaximum: Codable, Equatable {
            public typealias Units = TInsulin.Units

            public var value: Double?
            public var units: Units?
            
            public init(_ value: Double, _ units: Units = .units) {
                self.value = value
                self.units = units
            }
        }
        
        public struct Calculator: Codable, Equatable {
            public var enabled: Bool?
            public var insulin: Insulin?
            
            public init(enabled: Bool, insulin: Insulin) {
                self.enabled = enabled
                self.insulin = insulin
            }
            
            public struct Insulin: Codable, Equatable {
                public enum Units: String, Codable {
                    case hours
                    case minutes
                    case seconds
                }
                
                public var duration: Double?
                public var units: Units?
                
                public init(_ duration: Double, _ units: Units) {
                    self.duration = duration
                    self.units = units
                }
            }
        }
        
        public struct Extended: Codable, Equatable {
            public var enabled: Bool?
            
            public init(enabled: Bool) {
                self.enabled = enabled
            }
        }
    }
    
    public struct CarbohydrateRatioStart: Codable, Equatable {
        public var start: Int?
        public var amount: Double?
        
        public init(start: Int, amount: Double) {
            self.start = start
            self.amount = amount
        }
    }
    
    public struct Display: Codable, Equatable {
        public var bloodGlucose: BloodGlucose?
        
        public init(bloodGlucose: BloodGlucose) {
            self.bloodGlucose = bloodGlucose
        }
        
        public struct BloodGlucose: Codable, Equatable {
            public typealias Units = TBloodGlucose.Units
            
            public var units: Units?
            
            public init(_ units: Units) {
                self.units = units
            }
        }
    }
    
    public struct InsulinSensitivityStart: Codable, Equatable {
        public var start: Int?
        public var amount: Double?
        
        public init(start: Int, amount: Double) {
            self.start = start
            self.amount = amount
        }
    }
    
    public struct SuspendThreshold: Codable, Equatable {
        public typealias Units = TBloodGlucose.Units

        public var value: Double?
        public var units: Units?

        public init(_ value: Double, _ units: Units) {
            self.value = value
            self.units = units
        }
    }

    public struct Units: Codable, Equatable {
        public typealias BloodGlucoseUnits = TBloodGlucose.Units
        public typealias CarbohydrateUnits = TCarbohydrate.Units
        
        public var bloodGlucose: BloodGlucoseUnits?
        public var carbohydrate: CarbohydrateUnits?
        
        public init(bloodGlucose: BloodGlucoseUnits? = nil, carbohydrate: CarbohydrateUnits? = nil) {
            self.bloodGlucose = bloodGlucose
            self.carbohydrate = carbohydrate
        }
        
        private enum CodingKeys: String, CodingKey {
            case bloodGlucose = "bg"
            case carbohydrate = "carb"
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case activeScheduleName = "activeSchedule"
        case basal
        case basalRateSchedule = "basalSchedule"
        case basalRateSchedules = "basalSchedules"
        case basalRateSchedulesTimezoneOffset = "basalSchedulesTimezoneOffset"
        case bloodGlucoseTargetPreprandial = "bgTargetPreprandial"
        case bloodGlucoseTargetSchedule = "bgTarget"
        case bloodGlucoseTargetSchedules = "bgTargets"
        case bloodGlucoseTargetSchedulesTimezoneOffset = "bgTargetsTimezoneOffset"
        case bolus
        case carbohydrateRatioSchedule = "carbRatio"
        case carbohydrateRatioSchedules = "carbRatios"
        case carbohydrateRatioSchedulesTimezoneOffset = "carbRatiosTimezoneOffset"
        case display
        case dosingEnabled
        case insulinModel
        case insulinSensitivitySchedule = "insulinSensitivity"
        case insulinSensitivitySchedules = "insulinSensitivities"
        case insulinSensitivitySchedulesTimezoneOffset = "insulinSensitivitiesTimezoneOffset"
        case manufacturers
        case model
        case serialNumber
        case suspendThreshold
        case units
    }
}
