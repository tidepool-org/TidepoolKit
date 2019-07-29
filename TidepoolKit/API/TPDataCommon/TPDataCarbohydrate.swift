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

public struct TPDataCarbohydrate: TPData {
    public static var tpType: TPDataType { return .carbohydrate }

    public let dietaryFiber: Double?
    public let net: Double?
    public let sugars: Double?
    public let total: Double?
    public let units = "grams"
    
    public init?(net: Double, dietaryFiber: Double? = nil, sugars: Double? = nil, total: Double? = nil) {
        self.dietaryFiber = TPDataType.validateDouble(dietaryFiber, min: 0.0, max: 1000.0)
        self.net = TPDataType.validateDouble(net, min: 0.0, max: 1000.0)
        self.sugars = TPDataType.validateDouble(sugars, min: 0.0, max: 1000.0)
        self.total = TPDataType.validateDouble(total, min: 0.0, max: 1000.0)
        if self.net == nil {
            return nil
        }
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]

    public init?(rawValue: RawValue) {
        self.dietaryFiber = rawValue["dietaryFiber"] as? Double
        self.net = rawValue["net"] as? Double
        self.sugars = rawValue["sugars"] as? Double
        self.total = rawValue["total"] as? Double
        if let unitsIn = rawValue["units"] as? String {
            guard unitsIn == "grams" else {
                return nil
            }
        }
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        if let dietaryFiber = dietaryFiber {
            resultDict["dietaryFiber"] = dietaryFiber as Any
        }
        if let net = net {
            resultDict["net"] = net as Any
        }
        if let sugars = sugars {
            resultDict["sugars"] = sugars as Any
        }
        if let total = total {
            resultDict["total"] = total as Any
        }
        resultDict["units"] = units
        return resultDict
    }
    
    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
}

