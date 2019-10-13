//
//  TPDataset.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/20/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation


// Note: extend to other types as needed
public enum DatasetType: String, Encodable {
    case continuous = "continuous"
}

/// Login will return a TPUser in the TPSession object.
public class TPDataset: TPUserData, RawRepresentable {
    
    public let uploadId: String?
    public var client: TPDatasetClient
    public var deduplicator: TPDeduplicator

    public init(uploadId: String? = nil, client: TPDatasetClient? = nil, deduplicator: TPDeduplicator? = nil) {
        if let client = client {
            self.client = client
        } else {
            self.client = TPDatasetClient()
        }
        if let deduplicator = deduplicator {
             self.deduplicator = deduplicator
        } else {
            self.deduplicator = TPDeduplicator()
        }
        self.uploadId = uploadId
    }
    
    // MARK: - RawRepresentable

    public required init?(rawValue: [String : Any]) {
        self.uploadId = rawValue["uploadId"] as? String
        guard let deduplicatorDict = rawValue["deduplicator"] as? [String : Any] else {
            return nil
        }
        guard let deduplicator = TPDeduplicator(rawValue: deduplicatorDict) else {
            return nil
        }
        self.deduplicator = deduplicator
        guard let clientDict = rawValue["client"] as? [String : Any] else {
            return nil
        }
        guard let client = TPDatasetClient(rawValue: clientDict) else {
            return nil
        }
        self.client = client
    }
    
    public override var rawValue: [String : Any] {
        var result = [String: Any]()
        result["uploadId"] = uploadId
        result["client"] = client.rawValue
        result["deduplicator"] = deduplicator.rawValue
        return result
    }

}

