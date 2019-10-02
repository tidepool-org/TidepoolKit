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
}

public struct TPDataElevation: TPData {
    public static var tpType: TPDataType { return .elevation }
    
    public let value: Double  // -10000.0 <= x <= 10000.0 meters (and equivalent feet)
    public let units: ElevationUnits
    
    public init(value: Double, units: ElevationUnits) {
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
