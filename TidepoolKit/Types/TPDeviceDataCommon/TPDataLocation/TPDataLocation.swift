//
//  TPDataLocation.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataLocation: TPData {
    public static var tpType: TPDataType { return .location }

    // one or more of name and gps are required
	public let name: String?  // 1 <= len < 100]
	public let gps: TPDataGPS?
    
    public init(name: String? = nil, gps: TPDataGPS? = nil) {
        self.name = name
        self.gps = gps
    }

    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]

    public init?(rawValue: RawValue) {
        self.name = rawValue["name"] as? String
        self.gps = TPDataGPS.getSelfFromDict(rawValue)
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        rawValue["name"] = name
        gps?.addSelfToDict(&rawValue)
        return rawValue
    }
} 



