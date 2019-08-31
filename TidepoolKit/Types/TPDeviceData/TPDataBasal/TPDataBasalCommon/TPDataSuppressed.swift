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
    public let type: String = "basal"
    public var scheduleName: String?
    
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
        self.scheduleName = rawValue["scheduleName"] as? String
    }
    
    public var rawValue: RawValue {
        var dict: [String: Any] = [:]
        dict["deliveryType"] = self.deliveryType.rawValue
        dict["rate"] = self.rate
        dict["scheduleName"] = self.scheduleName
        dict["type"] = TPDataType.basal.rawValue
        return dict
    }

}
