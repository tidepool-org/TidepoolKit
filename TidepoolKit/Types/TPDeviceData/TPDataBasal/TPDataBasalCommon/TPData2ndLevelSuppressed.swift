//
//  TPData2ndLevelSuppressed.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 9/1/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// This is the same as TPDataSuppressed except that it cannot contain yet another suppressed field.
public struct TPData2ndLevelSuppressed: TPData {
    public static var tpType: TPDataType { return .suppressed }
    
    public var deliveryType: TPBasalDeliveryType
    public var rate: Double
    public var percent: Double?
    public var scheduleName: String?
    
    public init(_ deliveryType: TPBasalDeliveryType, rate: Double, percent: Double? = nil, scheduleName: String? = nil) {
        self.deliveryType = deliveryType
        self.rate = rate
        self.percent = percent
        self.scheduleName = scheduleName
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        guard let deliveryTypeStr = rawValue["deliveryType"] as? String  else {
            LogError("suppressed dict without delivery type: \(rawValue)")
            return nil
        }
        guard let deliveryType = TPBasalDeliveryType(rawValue: deliveryTypeStr) else {
            LogError("suppressed dict with unknown delivery type: \(rawValue)")
            return nil
        }
        self.deliveryType = deliveryType
        guard let rate = rawValue["rate"] as? NSNumber else {
            LogError("suppressed dict without rate: \(rawValue)")
            return nil
        }
        self.rate = rate.doubleValue
        if let percent = rawValue["percent"] as? NSNumber {
            self.percent = percent.doubleValue
        } else {
            self.percent = nil
        }
        self.scheduleName = rawValue["scheduleName"] as? String
     }
    
    public var rawValue: RawValue {
        var dict: [String: Any] = [:]
        dict["type"] = TPDataType.basal.rawValue
        dict["deliveryType"] = self.deliveryType.rawValue
        dict["rate"] = self.rate
        dict["percent"] = self.percent
        dict["scheduleName"] = self.scheduleName
        return dict
    }
    
}