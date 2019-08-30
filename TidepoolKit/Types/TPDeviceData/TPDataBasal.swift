//
//  TPDataBasal.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct Suppressed {
    public var deliveryType: String?
    public var rate: Double?
    public var type: String?
}

public class TPDataBasal: TPDeviceData, TPData {
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
        super.init(.basal, time: time)
    }

    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    required public init?(rawValue: RawValue) {
        return nil
        // todo: implement!
    }

    override public var rawValue: RawValue {
        // start with common data
        let dict = super.rawValue
        // add in type-specific data...
        // TODO: finish!
        return dict
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

