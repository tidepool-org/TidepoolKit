//
//  TPBasalTemporary.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/31/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPDataBasalTemporary: TPDataBasal {

//
// MARK: - Type specific data
//
    public let rate: Double
    public let percent: Double?
    public var suppressed: TPDataSuppressed?

    public init(time: Date, duration: TimeInterval, expectedDuration: TimeInterval? = nil, rate: Double, percent: Double? = nil, suppressed: TPDataSuppressed? = nil) {
        self.rate = rate
        self.percent = percent
        self.suppressed = suppressed
        if suppressed != nil {
            if suppressed?.deliveryType != .scheduled {
                LogError("Suppressed field for temp bolus must have delivery type == 'scheduled'!")
            }
        }
        super.init(time: time, deliveryType: .temp, duration: duration, expectedDuration: expectedDuration)
    }
    
    //
    // MARK: - RawRepresentable
    //

    required public init?(rawValue: RawValue) {
        guard let rate = rawValue["rate"] as? NSNumber else {
            return nil
        }
        self.rate = rate.doubleValue
        if let percent = rawValue["percent"] as? NSNumber {
            self.percent = percent.doubleValue
        } else {
            self.percent = nil
        }
        self.suppressed = TPDataSuppressed.getSelfFromDict(rawValue)
       // base properties in superclasses...
        super.init(rawValue: rawValue)

    }
    
    override public var rawValue: RawValue {
        // start with common data
        var dict = super.rawValue
        // add in type-specific data...
        dict["rate"] = self.rate
        dict["percent"] = self.percent
        self.suppressed?.addSelfToDict(&dict)
        return dict
    }

    
}
