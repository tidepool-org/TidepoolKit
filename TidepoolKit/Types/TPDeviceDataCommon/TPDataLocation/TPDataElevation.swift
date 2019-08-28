//
//  TPDataElevation.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/28/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum ElevationUnits: String, Codable {
    case feet = "feet"
    case meters = "meters"

    // service syntax check
    func inRange(_ value: Double) -> Bool {
        let kMetersMax: Double = 1000000.0
        let kMetersMin: Double = -20000.0
        let kMetersPerFoot: Double = 0.3048
        switch self {
        case .feet:
            return value >= kMetersMin/kMetersPerFoot && value <= kMetersMax/kMetersPerFoot
        case .meters:
            return value >= kMetersMin && value <= kMetersMax
        }
    }
}

public struct TPDataElevation: TPData {
    public static var tpType: TPDataType { return .elevation }
    
    public let value: Double  // -10000.0 <= x <= 10000.0 meters (and equivalent feet)
    public let units: ElevationUnits
    
    public init?(value: Double, units: ElevationUnits) {
        self.value = value
        self.units = units
        // validation...
        guard self.units.inRange(self.value) else {
            LogError("TPDataElevation init: value \(value) \(units.rawValue) out of range!")
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
        guard let units = ElevationUnits(rawValue: unitsStr) else {
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
