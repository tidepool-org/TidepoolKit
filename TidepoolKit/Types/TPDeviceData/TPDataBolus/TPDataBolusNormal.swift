//
//  TPDataBolusNormal.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/30/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPDataBolusNormal: TPDataBolus {
    
    public let normal: Double
    public let expectedNormal: Double?

    public init(time: Date, normal: Double, expectedNormal: Double? = nil) {
        self.normal = normal
        self.expectedNormal = expectedNormal
        // TPDeviceData fields
        super.init(time: time, subType: .normal)
    }
    
    // MARK: - RawRepresentable

    required public init?(rawValue: RawValue) {
        guard let normal = rawValue["normal"] as? NSNumber else {
            LogError("TPDataBolusNormal:init(rawValue) no normal found!")
            return nil
        }
        if let expectedNormal = rawValue["expectedNormal"] as? NSNumber {
            self.expectedNormal = expectedNormal.doubleValue
        } else {
            self.expectedNormal = nil
        }
        self.normal = normal.doubleValue
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        var rawValue = super.rawValue
        rawValue["normal"] = normal
        rawValue["expectedNormal"] = expectedNormal
        return rawValue
    }
}
