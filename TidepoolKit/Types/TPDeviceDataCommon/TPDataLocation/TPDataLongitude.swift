//
//  TPDataLongitude.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/28/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataLongitude: TPData {
    public static var tpType: TPDataType { return .longitude }
    
    public let value: Double     // -180.0 <= x <= 180.0
    public let units = "degrees"
    public init(value: Double) {
        self.value = value
    }
    
    public init(_ value: Double) {
        self.value = value
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
        guard unitsStr == self.units else {
            return nil
        }
        self.value = value
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        rawValue["value"] = value
        rawValue["units"] = units
        return rawValue
    }
    
}
