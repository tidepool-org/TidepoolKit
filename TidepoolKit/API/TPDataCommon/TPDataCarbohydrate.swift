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

public struct TPDataCarbohydrate: RawRepresentable {
    let dietaryFiber: Double?
    let net: Double?
    let sugars: Double?
    let total: Double?
    let units = "grams"

    static func validateDouble(_ value: Double?, min: Double? = nil, max: Double? = nil) -> Double? {
        var result: Double? = value
        guard let value = value else {
            return nil
        }
        if let min = min {
            if value < min {
                LogError("Err: value \(value) is less than minimum!")
                result = nil
            }
        }
        if let max = max {
            if value > max {
                LogError("Err: value \(value) is greater than maximum!")
               result = nil
            }
        }
        return result
    }
    
    public init?(net: Double, dietaryFiber: Double? = nil, sugars: Double? = nil, total: Double? = nil) {
        self.dietaryFiber = TPDataCarbohydrate.validateDouble(dietaryFiber, min: 0.0, max: 1000.0)
        self.net = TPDataCarbohydrate.validateDouble(net, min: 0.0, max: 1000.0)
        self.sugars = TPDataCarbohydrate.validateDouble(sugars, min: 0.0, max: 1000.0)
        self.total = TPDataCarbohydrate.validateDouble(total, min: 0.0, max: 1000.0)
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
            var result = "carbohydrate: "
            if let net = net {
                result += "\n net: \(net) \(units)"
            }
            if let dietaryFiber = dietaryFiber {
                result += "\n dietaryFiber: \(dietaryFiber)"
            }
            if let sugars = sugars {
                result += "\n sugars: \(sugars)"
            }
            if let total = total {
                result += "\n total: \(total)"
            }
            return result
        }
    }
}

