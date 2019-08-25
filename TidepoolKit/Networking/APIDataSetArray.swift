//
//  APIDataSetArray.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Used internally...
class APIDataSetArray: TPFetchable {
    
    let datasetArray: [TPDataset]

    init(_ datasetArray: [TPDataset]) {
        self.datasetArray = datasetArray
    }

    //
    // MARK: - methods private to framework!
    //

    class func dataSetsFromJsonData(_ data: Data) -> APIDataSetArray? {
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data)
            if let jsonArray = object as? [[String: Any]] {
                var items: [TPDataset] = []
                for jsonDict in jsonArray {
                    LogInfo("calling createFromJson on \(jsonDict)")
                    if let item = TPDataset(rawValue: jsonDict) {
                        items.append(item)
                    }
                }
                return APIDataSetArray(items)
            } else {
                LogError("Received data not json decodable!")
            }
        } catch (let error) {
            LogError("Received data not json decodable: \(error)")
        }
        return nil
    }
    
    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/v1/users/" + userId + "/data_sets?client.name=org.tidepool.mobile&size=1"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        return APIDataSetArray.dataSetsFromJsonData(data)
    }

}

/*
 Example service json:

    let jsonDataSets = """[
  {
    "modifiedTime" : "2018-10-25T22:33:13Z",
    "type" : "upload",
    "client" : {
      "version" : "2.1.5",
      "name" : "org.tidepool.mobile"
    },
    "id" : "a62779b825531b7632297c00e5624941",
    "createdTime" : "2018-10-25T22:33:13Z",
    "uploadId" : "a62779b825531b7632297c00e5624941",
    "dataSetType" : "continuous",
    "deduplicator" : {
      "version" : "1.0.0",
      "name" : "org.tidepool.deduplicator.dataset.delete.origin"
    }
  }
]""".data(using: .utf8)!

 */
