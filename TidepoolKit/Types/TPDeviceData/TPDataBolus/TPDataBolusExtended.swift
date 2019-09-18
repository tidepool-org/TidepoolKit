//
//  TPDataBolusExtended.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/30/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPDataBolusExtended: TPDataBolus {
    
    //
    // MARK: - Type specific data
    //
    
    public let extended: Double
    public let expectedExtended: Double?
    public let duration: TimeInterval
    public let expectedDuration: TimeInterval?

    public init(time: Date, extended: Double, expectedExtended: Double? = nil, duration: TimeInterval, expectedDuration: TimeInterval? = nil) {
        self.extended = extended
        self.expectedExtended = expectedExtended
        self.duration = duration
        self.expectedDuration = expectedDuration
        // TPDeviceData fields
        super.init(time: time, subType: .extended)
    }
    
    //
    // MARK: - RawRepresentable
    //
    required public init?(rawValue: RawValue) {
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
        NSLog("converted duration \(duration) ms into \(self.duration) sec!")
        if let expectedDuration = rawValue["expectedDuration"] as? NSNumber {
            self.expectedDuration = expectedDuration.doubleValue / 1000.0
        } else {
            self.expectedDuration = nil
        }
        // base properties in superclasses...
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        // start with common data
        var dict = super.rawValue
        // add in type-specific data...
        dict["extended"] = self.extended
        dict["expectedExtended"] = self.expectedExtended
        dict["duration"] = Int(self.duration * 1000.0) // convert to integer milliseconds!
        if let expectedDuration = self.expectedDuration {
            dict["expectedDuration"] = Int(expectedDuration * 1000.0)
        }
        return dict
    }
}