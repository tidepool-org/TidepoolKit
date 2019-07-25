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

/// Used internally...
class APIDataSetArray: Codable, TPFetchable {
    
    let dataSetArray: [APIDataSet]

    init(_ dataSetArray: [APIDataSet]) {
        self.dataSetArray = dataSetArray
    }

    var debugDescription: String {
        get {
            var result = "Data Sets: "
            for item in dataSetArray {
                result = result + "\n" + item.debugDescription
            }
            return result
        }
    }

    //
    // MARK: - methods private to framework!
    //

    class func dataSetsFromJsonData(_ data: Data) -> APIDataSetArray? {
        do {
            let decoder = JSONDecoder()
            let decodedJson = try decoder.decode([APIDataSet].self, from: data)
            return APIDataSetArray(decodedJson)
        } catch (let error) {
            print("caught throw: \(error)")
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
