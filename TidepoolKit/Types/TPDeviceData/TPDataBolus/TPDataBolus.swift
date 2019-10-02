//
//  TPDataBolus.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/30/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum TPBolusSubType: String, Encodable {
    case normal = "normal"
    case combination = "dual/square"
    case extended = "square"
}

public class TPDataBolus: TPDeviceData, TPData {
    
    // TPData protocol conformance
    public static var tpType: TPDataType { return .basal }
    
    public let subType: TPBolusSubType
    public var createdUserId: String?
    public var createdTime: Date?
    
    public init(time: Date, subType: TPBolusSubType) {
        self.subType = subType
        // TODO: formulation, etc...
        createdUserId = nil
        createdTime = nil
        super.init(.bolus, time: time)
    }
    
     // MARK: - RawRepresentable

    public typealias RawValue = [String: Any]
    
    required public init?(rawValue: RawValue) {
        guard let subTypeStr = rawValue["subType"] as? String else {
            return nil
        }
        guard let subType = TPBolusSubType(rawValue: subTypeStr) else {
            return nil
        }
        self.subType = subType
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        var dict = super.rawValue
        dict["subType"] = self.subType.rawValue
        // TODO: finish!
        return dict
    }
        
    class func createBolusFromJson(_ jsonDict: [String: Any]) -> TPDataBolus? {
        var tpDataBolus: TPDataBolus? = nil
        guard let subType = jsonDict["subType"] as? String else {
            LogError("bolus item has no subType field!")
            return nil
        }
        switch subType {
        case TPBolusSubType.normal.rawValue:
            tpDataBolus = TPDataBolusNormal(rawValue: jsonDict)
        case TPBolusSubType.combination.rawValue:
            tpDataBolus = TPDataBolusCombination(rawValue: jsonDict)
        case TPBolusSubType.extended.rawValue:
            tpDataBolus = TPDataBolusExtended(rawValue: jsonDict)
        default:
            LogError("bolus subType \(subType) not recognized!")
        }
        return tpDataBolus
    }
}
