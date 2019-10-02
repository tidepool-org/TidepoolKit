//
//  TPDataBasalScheduledOrAutomated.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/31/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPDataBasalAutoSchedCommon: TPDataBasal {
    
    public let rate: Double
    public var scheduleName: String?
    
    public init(time: Date, deliveryType: TPBasalDeliveryType, rate: Double, scheduleName: String? = nil, duration: TimeInterval, expectedDuration: TimeInterval? = nil) {
        self.rate = rate
        self.scheduleName = scheduleName
        super.init(time: time, deliveryType: deliveryType, duration: duration, expectedDuration: expectedDuration)
    }
    
    // MARK: - RawRepresentable

    required public init?(rawValue: RawValue) {
        guard let rate = rawValue["rate"] as? NSNumber else {
            return nil
        }
        self.rate = rate.doubleValue
        self.scheduleName = rawValue["scheduleName"] as? String
        super.init(rawValue: rawValue)
        
    }
    
    override public var rawValue: RawValue {
        var dict = super.rawValue
        dict["rate"] = self.rate
        dict["scheduleName"] = self.scheduleName
        return dict
    }
}
