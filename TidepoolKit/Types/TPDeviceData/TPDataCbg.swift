//
//  TPDataCbg.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import HealthKit

public class TPDataCbg: TPDeviceData, TPData {
    
    // TPData protocol
    
    public static var tpType: TPDataType { return .cbg }

    // Type specific data
    
    public let value: Double
    public let units: TPCbgUnit

    public init(time: Date, value: Double, units: TPCbgUnit) {
        self.value = value
        self.units = units
        super.init(.cbg, time: time)
    }
    
    // MARK: - RawRepresentable

    public typealias RawValue = [String: Any]

    required public init?(rawValue: RawValue) {
        guard let value = rawValue["value"] as? NSNumber else {
            LogError("TPDataCbg:init(rawValue) no value found!")
            return nil
        }
        guard let unitsString = rawValue["units"] as? String else {
            LogError("TPDataCbg:init(rawValue) no units found!")
            return nil
        }
        guard let units = TPCbgUnit(rawValue: unitsString) else {
            LogError("TPDataCbg:init(rawValue) invalid units found!")
            return nil
        }
        self.value = value.doubleValue
        self.units = units
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        // start with common data
        var rawValue = super.rawValue
        // add in type-specific data...
        rawValue["units"] = units.rawValue
        rawValue["value"] = value
        return rawValue
    }
    
}

    

