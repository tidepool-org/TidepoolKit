/*
 * Copyright (c) 2019, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */

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
        super.init(time: time)
    }
    
    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    required override public init?(rawValue: RawValue) {
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
        var result = self.baseRawValue(type(of: self).tpType)
        // add in type-specific data...
        result["units"] = units.rawValue as Any?
        result["value"] = value as Any?
        return result
    }
    
}

    


