//
//  TPDataHorizontalAccuracy.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/28/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum LocationAccuracyUnits: String, Codable {
    case feet = "feet"
    case meters = "meters"
}

public struct TPDataHorizontalAccuracy: TPData {
    
    public static var tpType: TPDataType { return .horizontalAccuracy }
    
    public let value: Double
    public let units: LocationAccuracyUnits
    
    public init(value: Double, units: LocationAccuracyUnits) {
        self.value = value
        self.units = units
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        guard let value = rawValue["value"] as? Double else {
            return nil
        }
        guard let unitsStr = rawValue["units"] as? String else {
            return nil
        }
        guard let units = LocationAccuracyUnits(rawValue: unitsStr) else {
            return nil
        }
        self.units = units
        self.value = value
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        rawValue["value"] = value
        rawValue["units"] = units.rawValue
        return rawValue
    }
}

public struct TPDataVerticalAccuracy: TPData {
    
    public static var tpType: TPDataType { return .verticalAccuracy }
    
    public let value: Double
    public let units: LocationAccuracyUnits
    
    public init(value: Double, units: LocationAccuracyUnits) {
        self.value = value
        self.units = units
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        guard let value = rawValue["value"] as? Double else {
            return nil
        }
        guard let unitsStr = rawValue["units"] as? String else {
            return nil
        }
        guard let units = LocationAccuracyUnits(rawValue: unitsStr) else {
            return nil
        }
        self.units = units
        self.value = value
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        rawValue["value"] = value
        rawValue["units"] = units.rawValue
        return rawValue
    }
}
