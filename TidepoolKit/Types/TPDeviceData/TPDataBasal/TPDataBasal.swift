//
//  TPDataBasal.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum TPBasalDeliveryType: String, Encodable {
    case automated = "automated"
    case scheduled = "scheduled"
    case suspend = "suspend"
    case temp = "temp"
}

public class TPDataBasal: TPDeviceData, TPData {
     
    // TPData protocol conformance
    public static var tpType: TPDataType { return .basal }

    public var deliveryType: TPBasalDeliveryType
    public let duration: TimeInterval
    public let expectedDuration: TimeInterval?

    public init(time: Date, deliveryType: TPBasalDeliveryType, duration: TimeInterval, expectedDuration: TimeInterval? = nil) {
        self.deliveryType = deliveryType
        self.duration = duration
        self.expectedDuration = expectedDuration
        super.init(.basal, time: time)
    }

    // MARK: - RawRepresentable

    public typealias RawValue = [String: Any]

    required public init?(rawValue: RawValue) {
        guard let deliveryTypeStr = rawValue["deliveryType"] as? String else {
            LogError("basal type missing deliveryType: \(rawValue)!")
            return nil
        }
        guard let deliveryType = TPBasalDeliveryType(rawValue: deliveryTypeStr) else {
            LogError("basal type missing valid deliveryType: \(rawValue)!")
            return nil
        }
        self.deliveryType = deliveryType
        guard let duration = rawValue["duration"] as? NSNumber else {
            LogError("TPDataBasalTemporary:init(rawValue) no duration found!")
            return nil
        }
        self.duration = duration.doubleValue / 1000.0   // convert from integer milliseconds
        if let expectedDuration = rawValue["expectedDuration"] as? NSNumber {
            self.expectedDuration = expectedDuration.doubleValue / 1000.0
        } else {
            self.expectedDuration = nil
        }
        super.init(rawValue: rawValue)
    }

    override public var rawValue: RawValue {
        var dict = super.rawValue
        dict["deliveryType"] = self.deliveryType.rawValue
        dict["duration"] = Int(self.duration * 1000.0) // convert to integer milliseconds!
        if let expectedDuration = self.expectedDuration {
            dict["expectedDuration"] = Int(expectedDuration * 1000.0)
        }
        return dict
    }
    
    class func createBasalFromJson(_ jsonDict: [String: Any]) -> TPDataBasal? {
        var tpDataBasal: TPDataBasal? = nil
        guard let deliveryType = jsonDict["deliveryType"] as? String else {
            LogError("basal item has no deliveryType field!")
            return nil
        }
        switch deliveryType {
        case TPBasalDeliveryType.automated.rawValue:
            tpDataBasal = TPDataBasalAutomated(rawValue: jsonDict)
        case TPBasalDeliveryType.scheduled.rawValue:
            tpDataBasal = TPDataBasalScheduled(rawValue: jsonDict)
        case TPBasalDeliveryType.temp.rawValue:
            tpDataBasal = TPDataBasalTemporary(rawValue: jsonDict)
        case TPBasalDeliveryType.suspend.rawValue:
            tpDataBasal = TPDataBasalSuppressed(rawValue: jsonDict)
        default:
            LogError("basal deliveryType \(deliveryType) not recognized!")
        }
        return tpDataBasal
    }

}

