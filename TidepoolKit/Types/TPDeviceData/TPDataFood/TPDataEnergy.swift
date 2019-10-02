//
//  TPDataEnergy.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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
    
    public let value: Double
    public let units: EnergyUnits

    public init(value: Double, units: EnergyUnits) {
        self.units = units
        self.value = value
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
        var rawValue: [String: Any] = [:]
        rawValue["value"] = value
        rawValue["units"] = units.rawValue
        return rawValue
    }

}


