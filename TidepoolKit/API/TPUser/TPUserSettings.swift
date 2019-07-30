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

public enum BGUnitType: String {
    case mmPerL = "mmol/L"  // should match service json values!
    case mgPerDl = "mg/dL"  // should match service json values!
}

struct BGUnits: Codable {
    let bg: String
}

struct BGTarget: Codable {
    let low: Double
    let high: Double
}

public class TPUserSettings: RawRepresentable {
    
    public let bgTargetUnits: BGUnitType?
    public let bgTargetLow: Double?
    public let bgTargetHigh: Double?
    
    public var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }

    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    required public init?(rawValue: RawValue) {
        var bgUnits: BGUnitType?
        if let units = rawValue["units"] as? [String: String] {
            if let bgUnitsStr = units["bg"] {
                bgUnits = BGUnitType(rawValue: bgUnitsStr)
                if bgUnits == nil {
                    LogError("TPUserSettings: invalid raw target unit type \(bgUnitsStr)")
                    return nil
                }
            }
        }
        self.bgTargetUnits = bgUnits

        var lowTarget: Double?
        var highTarget: Double?
        if let bgTarget = rawValue["bgTarget"] as? [String: Any] {
            if let lowNum = bgTarget["low"] as? NSNumber {
                lowTarget = lowNum.doubleValue
            }
            if let highNum = bgTarget["high"] as? NSNumber {
                highTarget = highNum.doubleValue
            }
        }
        self.bgTargetLow = lowTarget
        self.bgTargetHigh = highTarget
        
        if bgTargetUnits == nil, bgTargetLow == nil, bgTargetHigh == nil {
            LogError("TPUserSettings: init from rawValue failed")
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        if let units = bgTargetUnits {
            resultDict["units"] = ["bg" : units.rawValue]
        }
        var targetDict = [String: Double]()
        if let low = bgTargetLow {
            targetDict["low"] = low
        }
        if let high = bgTargetHigh {
            targetDict["high"] = high
        }
        if !targetDict.isEmpty {
            resultDict["bgTarget"] = targetDict
        }
        return resultDict
    }
}

