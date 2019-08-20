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

public enum DeduplicatorType {
    case dataset_delete_origin
    case device_deactivate_hash
    case device_truncate_dataset
    case none
}

// Note: extend to other types as needed
public enum DatasetType: String {
    case continuous = "continuous"
}

/// This is used to configure uploading; after creating a TPDataset, defaults may be overridden.
/// TODO: add validation for non-strongly-typed overrides!
public class TPDataset {
    
    public var clientName: String = "org.tidepool.tidepoolkit"
    public var deduplicator: DeduplicatorType = .dataset_delete_origin
    public var dataSetType: DatasetType = .continuous
    public var clientVersion: String

    // No required fields. After initialization, above fields can be changed!
    public init() {
        guard let version = Bundle(for: TidepoolKit.self).infoDictionary?["CFBundleShortVersionString"] as? String else {
            fatalError()
        }
        self.clientVersion = version
    }

    public var debugDescription: String {
        get {
            var result = "Dataset"
            result += "\n clientName: \(clientName)"
            result += "\n clientVersion: \(clientVersion)"
            result += "\n dataSetType: \(dataSetType.rawValue)"
            result += "\n deduplicator: \(DeduplicatorSpec.enumToStrDict[deduplicator]!)"
            return result
        }
    }

    //
    // MARK: - Framework private variables, methods
    //

}



