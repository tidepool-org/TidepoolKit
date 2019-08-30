//
//  TPDataCbg.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import HealthKit

public enum TPCbgUnit: String, Encodable {
    case milligramsPerDeciliter = "mg/dL"
    case millimolesPerLiter = "mmol/L"
    
    // service syntax check
    func inRange(_ value: Double) -> Bool {
        switch self {
        case .milligramsPerDeciliter:
            return value >= 0.0 && value <= 1000.0
        case .millimolesPerLiter:
            return value >= 0.0 && value <= 55.0
        }
    }
}

public class TPDataCbg: TPDeviceData, TPData {
    
    //
    // MARK: - TPData protocol
    //
    public static var tpType: TPDataType { return .cbg }

    //
    // MARK: - Type specific data
    //
    public let value: Double
    public let units: TPCbgUnit

    /// Only values acceptable to the Tidepool service are allowed in creating a TPDataCbg item.
    public init?(time: Date, value: Double, units: TPCbgUnit) {
        self.value = value
        self.units = units
        guard self.units.inRange(self.value) else {
            LogError("TPDataCbg init: value \(value) \(units.rawValue) out of range!")
            return nil
        }
        // TPSampleData fields
        super.init(.cbg, time: time)
    }
    
    //
    // MARK: - RawRepresentable
    //
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
        
        // base properties in superclass...
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        // start with common data
        var dict = super.rawValue
        // add in type-specific data...
        dict["units"] = units.rawValue
        dict["value"] = value
        return dict
    }
    
}

    


