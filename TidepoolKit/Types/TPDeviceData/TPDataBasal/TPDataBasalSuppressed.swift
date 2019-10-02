//
//  TPDataBasalSuppressed.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/31/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation


public class TPDataBasalSuppressed: TPDataBasal {
    
    public var suppressed: TPDataSuppressed?
    
    public init(time: Date, duration: TimeInterval, expectedDuration: TimeInterval? = nil, suppressed: TPDataSuppressed? = nil) {
        self.suppressed = suppressed
        super.init(time: time, deliveryType: .suspend, duration: duration, expectedDuration: expectedDuration)
    }
    
    // MARK: - RawRepresentable

    required public init?(rawValue: RawValue) {
        self.suppressed = TPDataSuppressed.getSelfFromDict(rawValue)
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        var dict = super.rawValue
        self.suppressed?.addSelfToDict(&dict)
        return dict
    }
    
    
}
