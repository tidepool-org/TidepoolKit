//
//  UserDataDecode.swift
//  TidepoolKitTest
//
//  Created by Larry Kenyon on 7/1/19.
//  Copyright © 2019 Tidepool. All rights reserved.
//

import Foundation

var jsonUserData = """
[
  {
    "uploadId" : "0f7394fb80e46fad990b6cb2fa034a24",
    "type" : "cbg",
    "payload" : {
      "Trend Arrow" : "Flat",
      "Transmitter Time" : "2019-04-06T23:55:06.000Z",
      "HKDeviceName" : "10386270000221",
      "Trend Rate" : -0.10000000000000001,
      "HKTimeZone" : "America/Los_Angeles",
      "Status" : "IN_RANGE"
    },
    "units" : "mmol/L",
    "id" : "996afef4050c0fd9271e2d9517bde367",
    "value" : 7.6045199999999999,
    "time" : "2019-04-06T23:55:06.000Z",
    "origin" : {
      "type" : "service",
      "payload" : {
        "sourceRevision" : {
          "operatingSystemVersion" : "12.2.0",
          "source" : {
            "bundleIdentifier" : "com.dexcom.G6",
            "name" : "Dexcom G6"
          },
          "productType" : "iPhone10,6",
          "version" : "15631"
        }
      },
      "id" : "65C55636-BD6F-4D62-9946-007734BE254E",
      "name" : "com.apple.HealthKit"
    }
  },
  {
    "uploadId" : "0f7394fb80e46fad990b6cb2fa034a24",
    "deliveryType" : "temp",
    "payload" : {
      "HKMetadataKeySyncVersion" : 1,
      "HKMetadataKeySyncIdentifier" : "74656d70426173616c20302e35373520323031392d30342d30365432333a35333a33385a203430372e36333235303030353234353231",
      "com.loopkit.InsulinKit.MetadataKeyScheduledBasalRate" : "0.8 IU/hr",
      "HasLoopKitOrigin" : 1,
      "HKInsulinDeliveryReason" : 1
    },
    "type" : "basal",
    "id" : "6f1e00831ba7d761af8d0a70c2979689",
    "duration" : 407632,
    "suppressed" : {
      "deliveryType" : "scheduled",
      "rate" : 0.80000000000000004,
      "type" : "basal"
    },
    "rate" : 1.3247226360275874,
    "time" : "2019-04-06T23:53:38.971Z",
    "origin" : {
      "type" : "service",
      "payload" : {
        "device" : {
          "localIdentifier" : "1F05E6F8",
          "firmwareVersion" : "2.8.0",
          "model" : "Eros",
          "softwareVersion" : "44.0",
          "name" : "Omnipod",
          "manufacturer" : "Insulet"
        },
        "sourceRevision" : {
          "version" : "53",
          "operatingSystemVersion" : "12.2.0",
          "source" : {
            "name" : "Loop",
            "bundleIdentifier" : "com.34SNZ39Q48.loopkit.Loop"
          },
          "productType" : "iPhone10,6"
        }
      },
      "id" : "F47B648B-5856-42B6-AA88-28AF2AA23BA9",
      "name" : "com.apple.HealthKit"
    }
  }]
""".data(using: .utf8)!

if let decodedUserData = APIUserDataArray.fromJsonData(jsonUserData) {
    print("\(String(describing: decodedUserData.debugDescription))")
    print("\n")
    
    let tpUserData = TPUserDataArray(decodedUserData)
    print("\(String(describing: tpUserData.debugDescription))")
    
} else {
    print("failed to decode jsonUserData into APIUserDataArray!")
}

class DateUtils {
    class func dateFromJSON(_ json: String?) -> Date? {
        if let json = json {
            var result = jsonDateFormatter.date(from: json)
            if result == nil {
                result = jsonAltDateFormatter.date(from: json)
            }
            return result
        }
        return nil
    }
    
    class func dateToJSON(_ date: Date) -> String {
        return jsonDateFormatter.string(from: date)
    }
    
    class var jsonDateFormatter : DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(identifier: "GMT")
                return dateFormatter
            }()
        }
        return Static.instance
    }
    
    class var jsonAltDateFormatter : DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                dateFormatter.timeZone = TimeZone(identifier: "GMT")
                return dateFormatter
            }()
        }
        return Static.instance
    }
}
