//
//  Validations.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 7/1/19.
//  Copyright © 2019 Tidepool. All rights reserved.
//

import Foundation

public enum TPCbgUnit {
    case milligramsPerDeciliter
    case millimolesPerLiter
    
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

let units: TPCbgUnit = .milligramsPerDeciliter
let inRange = units.inRange(90)
print("90 \(units.rawValue) in-range: \(inRange)")

if let cbgSample = TPDataCbg(nil, time: Date(), value: 90, units: .millimolesPerLiter) {
    print(cbgSample.debugDescription)
} else {
    print("create TPDataCbg failed!")
}

public struct Origin  {
    let id: String?
    let name: String?
    let type: String?
    let payload: [String: Any]?
    
    public init(id: String?, name: String?, type: String?, payload: [String : Any]?) {
        self.id = id
        self.name = name
        self.type = type
        self.payload = payload
    }
}

var payloadDict = [String: Any]()
payloadDict["sourceRevision"] = "revision A" as Any

let origin = Origin(id: nil, name: "org.tidepool.tidepoolKitTest", type: "service", payload: payloadDict)

var originDict: [String: Any] = [:]
if let id = origin.id {
    originDict["id"] = id as Any
}
if let name = origin.name {
    originDict["name"] = name as Any
}
if let type = origin.type {
    originDict["type"] = type as Any
}
if let payload = origin.payload {
    originDict["payload"] = payload as [String: Any]
}

if !JSONSerialization.isValidJSONObject(originDict) {
    print("originDict \(originDict) not serializable!")
}
