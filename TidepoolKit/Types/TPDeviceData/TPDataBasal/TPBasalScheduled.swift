//
//  TPBasalScheduled.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/31/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPDataBasalScheduled: TPDataBasalAutoSchedCommon {
    
    public init(time: Date, rate: Double, scheduleName: String? = nil, duration: TimeInterval, expectedDuration: TimeInterval? = nil) {
        
        super.init(time: time, deliveryType: .scheduled, rate: rate, scheduleName: scheduleName, duration: duration, expectedDuration: expectedDuration)
    }
    
    required public init?(rawValue: RawValue) {
        super.init(rawValue: rawValue)
    }
}

