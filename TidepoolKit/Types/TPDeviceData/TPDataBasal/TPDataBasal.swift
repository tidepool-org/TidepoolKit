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
        // TPDeviceData fields
        super.init(.basal, time: time)
    }

    // RawRepresentable protocol conformance

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
        // start with common data
        var dict = super.rawValue
        // add in type-specific data...
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

/* Example upload data:
[{
    "rate": 2,
    "origin": {
        "id": "D4F5A742-F56B-42AE-A8E2-14696ECC481C",
        "type": "service",
        "payload": {
            "sourceRevision": {
                "productType": "iPhone7,2",
                "operatingSystemVersion": "12.2.0",
                "source": {
                    "bundleIdentifier": "com.apple.Health",
                    "name": "Health"
                },
                "version": "12.2"
            }
        },
        "name": "com.apple.HealthKit"
    },
    "type": "basal",
    "duration": 3600000,
    "deliveryType": "temp",
    "payload": {
        "HKWasUserEntered": 1,
        "HKInsulinDeliveryReason": 1
    },
    "time": "2019-06-24T13:53:00.000Z"
    }]
*/

