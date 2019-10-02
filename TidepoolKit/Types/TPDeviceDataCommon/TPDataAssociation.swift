//
//  TPDataAssociation.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum AssociationType: String, Codable {
	case url = "url"
    case datum = "datum"
    case image = "image"
    case blob = "blob"
}

public struct TPDataAssociation: TPData {
    public static var tpType: TPDataType { return .association }

    public let type: AssociationType
	public let id: String?
	public let reason: String?
    public let url: String?

    public init(type: AssociationType, url: String? = nil, id: String? = nil, reason: String? = nil) {
        self.type = type
        self.url = url
        self.id = id
        self.reason = reason
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        guard let associationTypeStr = rawValue["type"] as? String else {
            return nil
        }
        guard let type = AssociationType(rawValue: associationTypeStr) else {
            return nil
        }
        self.type = type
        self.id = rawValue["id"] as? String
        self.url = rawValue["url"] as? String
        self.reason = rawValue["reason"] as? String
    }
    
    public var rawValue: RawValue {
        var associationDict: [String: Any] = [:]
        associationDict["type"] = type.rawValue
        associationDict["url"] = url
        associationDict["id"] = id
        associationDict["reason"] = reason
        return associationDict
    }

}




