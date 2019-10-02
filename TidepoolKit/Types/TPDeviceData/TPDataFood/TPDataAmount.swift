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
    
    public init(value: Double, units: String) {
        self.value = value
        self.units = units
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
        var rawValue: [String: Any] = [:]
        rawValue["value"] = value
        rawValue["units"] = units
        return rawValue
    }
}


