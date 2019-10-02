//
//  TPDataProtein.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataProtein: TPData {
    public static var tpType: TPDataType { return .protein }

    public let total: Double
    public let units = "grams"

    public init(total: Double) {
        self.total = total
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]

    public init?(rawValue: RawValue) {
        guard let total = rawValue["total"] as? Double else {
            return nil
        }
        self.total = total
        if let unitsIn = rawValue["units"] as? String {
            guard unitsIn == "grams" else {
                return nil
            }
        }
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        rawValue["total"] = total
        rawValue["units"] = units
        return rawValue
    }
    
}
