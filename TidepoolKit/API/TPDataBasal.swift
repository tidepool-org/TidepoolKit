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

public struct Suppressed {
    public var deliveryType: String?
    public var rate: Double?
    public var type: String?
}

public class TPDataBasal: TPData {
    
    public let rate: Double
    public let duration: Int
    public var suppressed: Suppressed?
    public var deliveryType: String?

    public init(_ id: String?, time: Date, rate: Double, duration: Int) {
        self.rate = rate
        self.duration = duration
        super.init(id: id, time: time)
        type = .basal
    }

    public override var debugDescription: String {
        get {
            var result = "\nuser data type: \(type.rawValue)"
            result += "\n rate: \(rate)"
            result += "\n duration: \(duration)"
            if let deliveryType = deliveryType {
                result += "\n deliveryType: \(deliveryType)"
            }
            if let suppressed = suppressed {
                result += "\n suppressed:"
                result += "\n   deliveryType: \(suppressed.deliveryType ?? "MISSING")"
                result += "\n   rate: \(suppressed.rate ?? 0)"
                result += "\n   type: \(suppressed.type ?? "MISSING")"
            }
            result += super.debugDescription
            return result
        }
    }
    
    //
    // MARK: - RawRepresentable
    //
    
    required public init?(rawValue: RawValue) {
        return nil
        // todo: implement!
    }

    public override var rawValue: RawValue {
        let result = super.rawValue
        // add in type-specific data...
        // TODO: finish!
        return result
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

