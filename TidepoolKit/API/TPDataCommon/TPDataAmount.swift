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

public struct TPDataAmount: TPData {
    public static var tpType: TPDataType { return .amount }
    
    public let  value: Double?
    public let  units: String?
    
    public init?(value: Double, units: String) {
        self.value = value
        self.units = units
        guard TPDataType.isValidDouble(value, min: 0.0) else {
            return nil
        }
        guard TPDataType.validateString(units, maxLen: 100) else {
            return nil
        }
    }

    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        self.value = rawValue["value"] as? Double
        self.units = rawValue["units"] as? String
        if value == nil {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["value"] = value as Any
        resultDict["units"] = units as Any
        return resultDict
    }
    
    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }

}


