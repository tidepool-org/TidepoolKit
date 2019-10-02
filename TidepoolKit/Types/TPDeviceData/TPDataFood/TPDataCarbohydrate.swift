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
    
    public init(net: Double, dietaryFiber: Double? = nil, sugars: Double? = nil, total: Double? = nil) {
        self.dietaryFiber = dietaryFiber
        self.net = net
        self.sugars = sugars
        self.total = total
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
        var rawValue: [String: Any] = [:]
        rawValue["dietaryFiber"] = dietaryFiber
        rawValue["net"] = net
        rawValue["sugars"] = sugars
        rawValue["total"] = total
        rawValue["units"] = units
        return rawValue
    }
    
}

