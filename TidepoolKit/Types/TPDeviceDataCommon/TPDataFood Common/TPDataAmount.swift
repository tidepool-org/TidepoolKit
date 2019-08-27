//
//  TPDataAmount.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataAmount: TPData {
    public static var tpType: TPDataType { return .amount }
    
    public let  value: Double
    public let  units: String
    
    public init?(value: Double, units: String) {
        self.value = value
        self.units = units
        if !isValidDouble(value, min: 0.0) { return nil }
        if !validateString(units, maxLen: 100) { return nil }
    }

    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        if let value = rawValue["value"] as? Double {
            self.value = value
        } else {
            return nil
        }
        if let units = rawValue["units"] as? String {
            self.units = units
        } else {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["value"] = value as Any
        resultDict["units"] = units as Any
        return resultDict
    }
}


