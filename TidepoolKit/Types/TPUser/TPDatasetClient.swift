//
//  TPDatasetClient.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/22/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDatasetClient: Equatable {
    
    public var name: String
    public var version: String
    
    public init(name: String? = nil, version: String? = nil) {
        if let name = name, let version = version {
            self.name = name
            self.version = version
        } else {
            self.name = "org.tidepool.tidepoolkit"
            guard let version = Bundle(for: TidepoolKit.self).infoDictionary?["CFBundleShortVersionString"] as? String else {
                fatalError()
            }
            self.version = version
        }
    }

    public static func == (lhs: TPDatasetClient, rhs: TPDatasetClient) -> Bool {
        return lhs.name == rhs.name && lhs.version == rhs.version
    }

    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: [String : Any]) {
        guard let name = rawValue["name"] as? String else {
            return nil
        }
        self.name = name
        guard let version = rawValue["version"] as? String else {
            return nil
        }
        self.version = version
    }
    
    public var rawValue: [String : Any] {
        var result = [String: Any]()
        result["name"] = self.name as Any
        result["version"] = self.version as Any
        return result
    }

}
