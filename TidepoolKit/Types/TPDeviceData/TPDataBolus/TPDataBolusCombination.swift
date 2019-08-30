//
//  TPDataBolusCombination.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/30/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPDataBolusCombination: TPDataBolus {
    
    //
    // MARK: - Type specific data
    //
    
    public let normal: Double
    public let expectedNormal: Double?
    public let extended: Double
    public let expectedExtended: Double?
    public let duration: TimeInterval

    public init?(time: Date, normal: Double, expectedNormal: Double? = nil, extended: Double, expectedExtended: Double? = nil, duration: TimeInterval) {
        self.normal = normal
        self.expectedNormal = expectedNormal
        self.extended = extended
        self.expectedExtended = expectedExtended
        self.duration = duration
        // TPDeviceData fields
        super.init(time: time, subType: .combination)
    }
    
    //
    // MARK: - RawRepresentable
    //
    required public init?(rawValue: RawValue) {
        guard let normal = rawValue["normal"] as? NSNumber else {
            LogError("TPDataBolusNormal:init(rawValue) no normal found!")
            return nil
        }
        self.normal = normal.doubleValue
        if let expectedNormal = rawValue["expectedNormal"] as? NSNumber {
            self.expectedNormal = expectedNormal.doubleValue
        } else {
            self.expectedNormal = nil
        }
        guard let extended = rawValue["extended"] as? NSNumber else {
            LogError("TPDataBolusNormal:init(rawValue) no extended found!")
            return nil
        }
        self.extended = extended.doubleValue
        if let expectedExtended = rawValue["expectedExtended"] as? NSNumber {
            self.expectedExtended = expectedExtended.doubleValue
        } else {
            self.expectedExtended = nil
        }
        guard let duration = rawValue["duration"] as? NSNumber else {
            LogError("TPDataBolusNormal:init(rawValue) no duration found!")
            return nil
        }
        self.duration = duration.doubleValue / 1000.0   // convert from milliseconds to seconds
        
        // base properties in superclasses...
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        // start with common data
        var dict = super.rawValue
        // add in type-specific data...
        dict["normal"] = self.normal
        dict["expectedNormal"] = self.expectedNormal
        dict["extended"] = self.extended
        dict["expectedExtended"] = self.expectedExtended
        dict["duration"] = self.duration / 1000.0 // convert to milliseconds!
        return dict
    }
}
