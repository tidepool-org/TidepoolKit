//
//  TPDataCarbohydrate.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataCarbohydrate: TPData {
    public static var tpType: TPDataType { return .carbohydrate }

    public let dietaryFiber: Double?
    public let net: Double?
    public let sugars: Double?
    public let total: Double?
    public let units = "grams"
    
    public init?(net: Double, dietaryFiber: Double? = nil, sugars: Double? = nil, total: Double? = nil) {
        self.dietaryFiber = dietaryFiber
        self.net = net
        self.sugars = sugars
        self.total = total
        // validate
        if !TPDataType.isValidDoubleOrNil(dietaryFiber, min: 0.0, max: 1000.0) { return nil }
        if !TPDataType.isValidDouble(net, min: 0.0, max: 1000.0) { return nil }
        if !TPDataType.isValidDoubleOrNil(sugars, min: 0.0, max: 1000.0) { return nil }
        if !TPDataType.isValidDoubleOrNil(total, min: 0.0, max: 1000.0) { return nil }
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
    
}

