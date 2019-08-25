//
//  TPDataPayload.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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
    
}
