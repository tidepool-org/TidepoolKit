//
//  TPDataSuppressed.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/31/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataSuppressed: TPData {
    public static var tpType: TPDataType { return .suppressed }

    public var deliveryType: TPBasalDeliveryType
    public var rate: Double
    public var percent: Double?
    public var scheduleName: String?
    public var suppressed: TPData2ndLevelSuppressed?

    public init(_ deliveryType: TPBasalDeliveryType, rate: Double, percent: Double? = nil, scheduleName: String? = nil, suppressed: TPData2ndLevelSuppressed? = nil) {
        self.deliveryType = deliveryType
        self.rate = rate
        self.percent = percent
        self.scheduleName = scheduleName
        self.suppressed = suppressed
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
        self.suppressed = TPData2ndLevelSuppressed.getSelfFromDict(rawValue)
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        rawValue["type"] = TPDataType.basal.rawValue
        rawValue["deliveryType"] = self.deliveryType.rawValue
        rawValue["rate"] = self.rate
        rawValue["percent"] = self.percent
        rawValue["scheduleName"] = self.scheduleName
        self.suppressed?.addSelfToDict(&rawValue)
        return rawValue
    }

}
