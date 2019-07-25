//
//  TPDataset.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/20/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

// Note: extend to other types as needed
public enum DataSetType: String, Encodable {
    case normal = "normal"
    case continuous = "continuous"
}

/// Login will return a TPUser in the TPSession object.
public class TPDataset: TPUserData, RawRepresentable {
    
    public let uploadId: String?
    public var client: TPDatasetClient
    public var deduplicator: TPDeduplicator
    public var dataSetType: DataSetType?

    public init(uploadId: String? = nil, client: TPDatasetClient? = nil, deduplicator: TPDeduplicator? = nil, dataSetType: DataSetType? = nil) {
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
        self.dataSetType = dataSetType
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

        if let rawDataSetType = rawValue["dataSetType"] as? String,
            let dataSetType = DataSetType(rawValue: rawDataSetType) {
            self.dataSetType = dataSetType
        }

        self.client = client
    }
    
    public override var rawValue: [String : Any] {
        var result = [String: Any]()
        result["uploadId"] = uploadId
        result["client"] = client.rawValue
        result["deduplicator"] = deduplicator.rawValue
        if let dataSetType = dataSetType {
            result["dataSetType"] = dataSetType.rawValue
        }
        return result
    }

}

