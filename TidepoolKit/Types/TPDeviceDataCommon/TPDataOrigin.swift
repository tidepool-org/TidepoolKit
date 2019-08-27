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
        guard !self.rawValue.isEmpty else {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var originDict: [String: Any] = [:]
        originDict["id"] = id
        originDict["name"] = name
        originDict["type"] = type?.rawValue
        originDict["version"] = version
        // Note: the following is equivalent to originDict[TPDataPayload.typeName] = payload?.rawValue, or originDict["payload"] = payload?.rawValue
        payload?.addSelfToDict(&originDict)
        return originDict
    }
    
}

