/*
 * Copyright (c) 2019, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */

import Foundation

public enum EnergyUnits: String {
    case calories = "calories"
    case kilocalories = "kilocalories" /* (aka dietary Calorie)*/
    case joules = "joules"
    case kilojoules = "kilojoules"
    
    static let kKilojoulesPerKilocalorie = 4.1858
    static let kKilocaloriesMaximum = 10000.0
    static let kKilocaloriesMinimum = 0.0
    static let kCaloriesMaximum     = kKilocaloriesMaximum * 1000.0
    static let kCaloriesMinimum     = kKilocaloriesMinimum * 1000.0
    static let kJoulesMaximum       = kKilojoulesMaximum * 1000.0
    static let kJoulesMinimum       = kKilojoulesMinimum * 1000.0
    static let kKilojoulesMaximum   = kKilocaloriesMaximum * kKilojoulesPerKilocalorie
    static let kKilojoulesMinimum   = kKilocaloriesMinimum * kKilojoulesPerKilocalorie
    
    func min() -> Double {
        switch self {
        case .calories: return EnergyUnits.kCaloriesMinimum
        case .kilocalories: return EnergyUnits.kKilocaloriesMinimum
        case .joules: return EnergyUnits.kJoulesMinimum
        case .kilojoules: return EnergyUnits.kKilojoulesMinimum
        }
    }
    
    func max() -> Double {
        switch self {
        case .calories: return EnergyUnits.kCaloriesMaximum
        case .kilocalories: return EnergyUnits.kKilocaloriesMaximum
        case .joules: return EnergyUnits.kJoulesMaximum
        case .kilojoules: return EnergyUnits.kKilojoulesMaximum
        }
    }

}

public struct TPDataEnergy : TPData {
    public static var tpType: TPDataType { return .energy }
    
    public let value: Double         // 0.0 <= x < 10000.0 for kilocalories, converted for other types; 4.1848 joules / calories]
    public let units: EnergyUnits

    public init?(value: Double, units: EnergyUnits) {
        self.units = units
        self.value = value
        if TPDataType.validateDouble(value, min: units.min(), max:  units.max()) == nil {
            return nil
        }
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        guard let value = rawValue["value"] as? Double else {
            return nil
        }
        self.value = value
        guard let unitsStr = rawValue["units"] as? String else {
            return nil
        }
        guard let units = EnergyUnits(rawValue: unitsStr) else {
            return nil
        }
        self.units = units
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["value"] = value as Any
        resultDict["units"] = units.rawValue
        return resultDict
    }
    
    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
}


