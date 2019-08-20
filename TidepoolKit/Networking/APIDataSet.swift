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

import UIKit

/// Used internally...
class APIDataSet: Codable {
    
    // post response on a create comes back in a "data" object:
    let data: APIDataSet?

    public var uploadId: String?

    // create json post takes these fields of a dataset:
    let dataSetType: String?
    
    struct Deduplicator: Codable {
        let name: String?
    }
    let deduplicator: Deduplicator?
    
    struct Client: Codable {
        let name: String?
        let version: String?
    }
    let client: Client?
    
    // This initializer is used to create an APIDataSet without uploadId, used for the create call.
    init(_ tpDataSet: TPDataset) {
        self.deduplicator = Deduplicator(name: DeduplicatorSpec.enumToStrDict[tpDataSet.deduplicator]!)
        self.dataSetType = tpDataSet.dataSetType.rawValue
        self.client = Client(name: tpDataSet.clientName, version: tpDataSet.clientVersion)
        self.data = nil
        self.uploadId = nil
    }

    func matchesDataset(_ tpDataSet: TPDataset) -> Bool {
        guard let clientName = client?.name, let clientVersion = client?.version, let dataSetType = dataSetType, let deduplicatorName = deduplicator?.name else {
            LogInfo("APIDataSet incomplete!")
            return false
        }
        if tpDataSet.clientName != clientName {
            LogInfo("client name mismatch")
            return false
        }
        if tpDataSet.clientVersion != clientVersion {
            LogInfo("client version mismatch")
           return false
        }
        guard let deduplicatorSpec = DeduplicatorSpec(deduplicatorName) else {
            LogInfo("dataset deduplicator invalid!")
            return false
        }
        if deduplicatorSpec.type != tpDataSet.deduplicator {
            LogInfo("deduplicator mismatch")
            return false
        }
        if tpDataSet.dataSetType.rawValue != dataSetType {
            LogInfo("datasetType mismatch")
            return false
        }
        LogInfo("matched!")
        return true
    }
    
    public var debugDescription: String {
        get {
            var result = "UploadId: "
            if let uploadId = uploadId {
                result = result + uploadId
            }
            if let data = data, let responseId = data.uploadId {
                result = result + "\ncreated upload id: \(responseId)"
            }
            if let client = client {
                result = result + "\nclient name: \(client.name ?? "")"
                result = result + "\nclient version: \(client.version ?? "")"
            }
            if let deduplicator = deduplicator {
                result = result + "\ndeduplicator name: \(deduplicator.name ?? "")"
            }
            return result
        }
    }

    //
    // MARK: - methods private to framework!
    //
    
    class func apiDataSetFromJsonData(_ data: Data) -> APIDataSet? {
        return jsonToObject(data)
    }

}

extension APIDataSet: TPPostable {
    //
    // MARK: - TPPostable protocol conformance methods
    //
    
    // Used by API to extend baseurl for a post request
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/v1/users/" + userId + "/data_sets"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        if let dataSet = APIDataSet.apiDataSetFromJsonData(data) {
            if dataSet.uploadId == nil {
                dataSet.uploadId = dataSet.data?.uploadId
            }
            return dataSet
        }
        return nil
    }

    func postBodyData() -> Data? {
        return objectToJson(self)
    }

}

struct DeduplicatorSpec: Equatable {
    
    var type: DeduplicatorType = .dataset_delete_origin

    var name: String {
        get {
            return DeduplicatorSpec.enumToStrDict[type]!
        }
    }

    init(_ type: DeduplicatorType? = nil) {
        self.type = type ?? .dataset_delete_origin
    }
    
    init?(_ str: String) {
        if let type = DeduplicatorSpec.strToEnumDict[str] {
            self.type = type
        } else if let type = DeduplicatorSpec.altStrToEnumDict[str] {
            self.type = type
        } else {
            return nil
        }
    }

    static func == (lhs: DeduplicatorSpec, rhs: DeduplicatorSpec) -> Bool {
        return lhs.type == rhs.type
    }

    static let strToEnumDict: [String: DeduplicatorType] = [
        "org.tidepool.deduplicator.dataset.delete.origin": .dataset_delete_origin,
        "org.tidepool.deduplicator.device.deactivate.hash": .device_deactivate_hash,
        "org.tidepool.deduplicator.device.truncate.dataset": .device_truncate_dataset,
        "org.tidepool.deduplicator.none": .none,
    ]
    
    static let enumToStrDict: [DeduplicatorType: String] = [
        .dataset_delete_origin : "org.tidepool.deduplicator.dataset.delete.origin",
        .device_deactivate_hash : "org.tidepool.deduplicator.device.deactivate.hash",
        .device_truncate_dataset: "org.tidepool.deduplicator.device.truncate.dataset",
        .none: "org.tidepool.deduplicator.none"
    ]
    
    static let altStrToEnumDict: [String: DeduplicatorType] = [
        "org.tidepool.continuous.origin": .dataset_delete_origin,
        "org.tidepool.hash-deactivate-old": .device_deactivate_hash,
        "org.tidepool.truncate": .device_truncate_dataset,
        "org.tidepool.continuous": .none,
    ]
}

/*
 Example service json:
 
 // post this json to service to create a new dataset:
 
 let jsonCreatePostJson = """{
    "dataSetType": "continuous",
    "client": {
        "version": "1.0.0",
        "name": "org.tidepool.tidepoolkit"
        },
    "deduplicator": {
        "name": "org.tidepool.deduplicator.dataset.delete.origin"
    }
 }""".data(using: .utf8)!
 
 // service response on a create call:
 let jsonCreateResponse = """{
    "data": {
        "createdTime": "2019-06-14T21:26:04.96Z",
        "deduplicator": {
            "name": "org.tidepool.deduplicator.dataset.delete.origin",
            "version": "1.0.0"
        },
        "id": "deef1451c20a7304abd1ea0eaabbf15a",
        "modifiedTime": "2019-06-14T21:26:04.963Z",
        "type": "upload",
        "uploadId": "deef1451c20a7304abd1ea0eaabbf15a",
        "client": {
            "name": "org.tidepool.tidepoolkit",
            "version": "1.0.0"
        },
        "dataSetType": "continuous"
    },
    "meta": {
        "trace": {
            "request": "2ee462f01520a54a8849cd71d3bff21f"
        }
    }
 }""".data(using: .utf8)!
 
 
 */
