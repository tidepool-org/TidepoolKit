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
    func inRange(_ value: Float) -> Bool {
        switch self {
        case .milligramsPerDeciliter:
            return value >= 0.0 && value <= 1000.0
        case .millimolesPerLiter:
            return value >= 0.0 && value <= 55.0
        }
    }
}

public class TPDataCbg: TPData {
    //
    // type specific data
    //
    public let value: Float
    public let units: TPCbgUnit

    /// Only values acceptable to the Tidepool service are allowed in creating a TPDataCbg item.
    public init?(_ id: String?, time: Date, value: Float, units: TPCbgUnit) {
        self.value = value
        self.units = units
        guard self.units.inRange(self.value) else {
            LogError("TPDataCbg init: value \(value) \(units.rawValue) out of range!")
            return nil
        }
        super.init(id: id, time: time)
        self.type = .cbg
    }
    
    public override var debugDescription: String {
        get {
            var result = "\n type: \(type.rawValue)"
            result += "\n value: \(value) \(units)"
            result += super.debugDescription
            return result
        }
    }
    
    //
    // MARK: - RawRepresentable
    //

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
        self.value = value.floatValue
        self.units = units
        super.init(rawValue: rawValue)
    }
    
    public override var rawValue: RawValue {
        var result = super.rawValue
        // add in type-specific data...
        result["units"] = units.rawValue as Any?
        result["value"] = value as Any?
        return result
    }
    
}

    


