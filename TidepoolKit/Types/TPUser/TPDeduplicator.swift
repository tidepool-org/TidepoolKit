//
//  TPDeduplicator.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/22/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum DeduplicatorType: String, Encodable {
    case dataset_delete_origin = "org.tidepool.deduplicator.dataset.delete.origin"
    case device_deactivate_hash = "org.tidepool.deduplicator.device.deactivate.hash"
    case device_truncate_dataset = "org.tidepool.deduplicator.device.truncate.dataset"
    case none = "org.tidepool.deduplicator.none"
}

public struct TPDeduplicator: RawRepresentable, Equatable {
    public var type: DeduplicatorType
    public var version: String?
    
    public init(type: DeduplicatorType = .dataset_delete_origin, version: String? = nil) {
        self.type = type
        self.version = version
    }
    
    public static func == (lhs: TPDeduplicator, rhs: TPDeduplicator) -> Bool {
        return lhs.type == rhs.type
    }

    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: [String : Any]) {
        guard let deduplicatorStr = rawValue["name"] as? String else {
            return nil
        }
        if let type = DeduplicatorType(rawValue: deduplicatorStr) {
            self.type = type
        } else if let type = altStrToEnumDict[deduplicatorStr] {
            self.type = type
        } else {
            return nil
        }
        self.version = rawValue["version"] as? String
    }
    
    public var rawValue: [String : Any] {
        var result = [String: Any]()
        result["name"] = self.type.rawValue as Any
        result["version"] = self.version as Any
        return result
    }
    
    let altStrToEnumDict: [String: DeduplicatorType] = [
        "org.tidepool.continuous.origin": .dataset_delete_origin,
        "org.tidepool.hash-deactivate-old": .device_deactivate_hash,
        "org.tidepool.truncate": .device_truncate_dataset,
        "org.tidepool.continuous": .none,
    ]

    
}
