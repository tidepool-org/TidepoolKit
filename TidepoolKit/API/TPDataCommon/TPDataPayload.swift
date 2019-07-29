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

// Note: If TPDataPayload is initialized with values of type Date, these will be turned into String types compatible with the Tidepool service.
public struct TPDataPayload: TPData {
    public static var tpType: TPDataType { return .payload }
    
    public let payload: [String: Any]
    
    public init?(_ payload: [String: Any]) {
        self.payload = payload
        var payload = payload
        for (key, value) in payload {
            // TODO: document this time format adjust!
            if let dateValue = value as? Date {
                payload[key] = DateUtils.dateToJSON(dateValue)
            }
        }
        if !JSONSerialization.isValidJSONObject(payload) {
            LogError("Invalid payload failed to serialize: \(String(describing: payload))")
            return nil
        }
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        self.payload = rawValue
    }
    
    public var rawValue: RawValue {
        return self.payload
    }
    
    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
}
