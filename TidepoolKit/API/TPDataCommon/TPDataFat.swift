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

public struct TPDataFat: TPData {
    public static var tpType: TPDataType { return .fat }

    public let total: Double?
    public let units = "grams"
    
    public init?(total: Double) {
        self.total = TPDataType.validateDouble(total, min: 0.0, max: 1000.0)
        if self.total == nil {
            return nil
        }
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        self.total = rawValue["total"] as? Double
        if let unitsIn = rawValue["units"] as? String {
            guard unitsIn == "grams" else {
                return nil
            }
        }
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        if let total = total {
            resultDict["total"] = total as Any
            resultDict["units"] = units
        }
        return resultDict
    }
    
    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
}

