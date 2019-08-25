//
//  TPDataOrigin.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum OriginType: String, Encodable {
    case device = "device"
    case manual = "manual"
    case service = "service"
}

public struct TPDataOrigin: TPData {
    public static var tpType: TPDataType { return .origin }

    public let id: String?
    public let name: String?
    public let type: OriginType?
    public let version: String?
    public let payload: TPDataPayload?

    public init?(id: String? = nil, name: String? = nil, type: OriginType? = nil, version: String? = nil, payload: TPDataPayload? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.version = version
        self.payload = payload
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]

    public init?(rawValue: RawValue) {
        self.id = rawValue["id"] as? String
        self.name = rawValue["name"] as? String
        if let originTypeStr = rawValue["type"] as? String {
            self.type = OriginType(rawValue: originTypeStr)
        } else {
            self.type = nil
        }
        self.version = rawValue["version"] as? String
        self.payload = TPDataPayload.getSelfFromDict(rawValue)
        if id == nil && name == nil && type == nil && version == nil && payload == nil {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var originDict: [String: Any] = [:]
        if let id = id {
            originDict["id"] = id as Any
        }
        if let name = name {
            originDict["name"] = name as Any
        }
        if let type = type {
            originDict["type"] = type.rawValue as Any
        }
        if let version = version {
            originDict["version"] = version as Any
        }
        // Note: the following is equivalent to originDict[TPDataPayload.typeName] = payload?.rawValue, or originDict["payload"] = payload?.rawValue
        payload?.addSelfToDict(&originDict)
        return originDict
    }
    
}

