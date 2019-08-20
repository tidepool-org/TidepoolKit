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

public struct TPDataOrigin: TPData {
    public static var tpType: TPDataType { return .origin }

    public let id: String?
    public let name: String?
    public let type: String?
    public let payload: TPDataPayload?

    public init?(id: String? = nil, name: String? = nil, type: String? = nil, payload: TPDataPayload? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.payload = payload
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]

    public init?(rawValue: RawValue) {
        self.id = rawValue["id"] as? String
        self.name = rawValue["name"] as? String
        self.type = rawValue["type"] as? String
        self.payload = TPDataPayload.getSelfFromDict(rawValue)
        if id == nil && name == nil && type == nil && payload == nil {
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
            originDict["type"] = type as Any
        }
        // Note: the following is equivalent to originDict[TPDataPayload.typeName] = payload?.rawValue, or originDict["payload"] = payload?.rawValue
        payload?.addSelfToDict(&originDict)
        return originDict
    }
    
}

