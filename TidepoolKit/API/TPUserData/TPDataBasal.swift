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

public class TPDataBasal: TPUserData, TPData {
    
    //
    // MARK: - TPData protocol
    //
    public static var tpType: TPDataType { return .basal }
    
    //
    // MARK: - Type specific data
    //

    public let rate: Double
    public let duration: Int
    public var suppressed: Suppressed?
    public var deliveryType: String?

    public init?(time: Date, rate: Double, duration: Int) {
        self.rate = rate
        self.duration = duration
        // TPSampleData fields
        super.init(time: time)
    }

    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    required override public init?(rawValue: RawValue) {
        return nil
        // todo: implement!
    }

    override public var rawValue: RawValue {
        // start with common data
        let result = self.baseRawValue(type(of: self).tpType)
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

