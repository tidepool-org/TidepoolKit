//
//  TPUserSettings.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum BGUnitType: String {
    case mmPerL = "mmol/L"  // should match service json values!
    case mgPerDl = "mg/dL"  // should match service json values!
}

public struct BGUnits: Codable {
    public let bg: String
}

public struct BGTarget: Codable {
    public let low: Double
    public let high: Double
}

public class TPUserSettings: TPUserData, RawRepresentable {
    
    public let bgTargetUnits: BGUnitType?
    public let bgTargetLow: Double?
    public let bgTargetHigh: Double?
    
    // MARK: - RawRepresentable
    
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
    
    public override var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        if let units = bgTargetUnits {
            rawValue["units"] = ["bg" : units.rawValue]
        }
        var targetDict = [String: Double]()
        if let low = bgTargetLow {
            targetDict["low"] = low
        }
        if let high = bgTargetHigh {
            targetDict["high"] = high
        }
        if !targetDict.isEmpty {
            rawValue["bgTarget"] = targetDict
        }
        return rawValue
    }
}

