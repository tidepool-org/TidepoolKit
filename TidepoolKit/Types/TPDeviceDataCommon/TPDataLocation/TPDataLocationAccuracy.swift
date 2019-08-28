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
    
    // service syntax check
    func inRange(_ value: Double) -> Bool {
        let kMetersMax: Double = 1000.0
        let kMetersMin: Double = 0.0
        let kMetersPerFoot: Double = 0.3048
        switch self {
        case .feet:
            return value >= kMetersMin/kMetersPerFoot && value <= kMetersMax/kMetersPerFoot
        case .meters:
            return value >= kMetersMin && value <= kMetersMax
        }
    }
}

public struct TPDataHorizontalAccuracy: TPData {
    
    public static var tpType: TPDataType { return .horizontalAccuracy }
    
    public let value: Double
    public let units: LocationAccuracyUnits
    
    public init?(value: Double, units: LocationAccuracyUnits) {
        self.value = value
        self.units = units
        // validation...
        guard self.units.inRange(self.value) else {
            LogError("TPDataHorizontalAccuracy init: value \(value) \(units.rawValue) out of range!")
            return nil
        }
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
        var dict: [String: Any] = [:]
        dict["value"] = value
        dict["units"] = units.rawValue
        return dict
    }
}

public struct TPDataVerticalAccuracy: TPData {
    
    public static var tpType: TPDataType { return .verticalAccuracy }
    
    public let value: Double
    public let units: LocationAccuracyUnits
    
    public init?(value: Double, units: LocationAccuracyUnits) {
        self.value = value
        self.units = units
        // validation...
        guard self.units.inRange(self.value) else {
            LogError("TPDataVerticalAccuracy init: value \(value) \(units.rawValue) out of range!")
            return nil
        }
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
        var dict: [String: Any] = [:]
        dict["value"] = value
        dict["units"] = units.rawValue
        return dict
    }
}
