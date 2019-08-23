//
//  TPDatasetExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/22/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension TPDataset: TPPostable, TPFetchable, Equatable {
    //
    // MARK: - Equatable
    //
    public static func == (lhs: TPDataset, rhs: TPDataset) -> Bool {
        guard lhs.client == rhs.client else {
            LogInfo("client mismatch")
            return false
        }
        guard lhs.deduplicator == rhs.deduplicator else {
            LogInfo("deduplicator mismatch")
            return false
        }
        return true
   }
    
    //
    // MARK: - Postable
    //
    func postBodyData() -> Data? {
        do {
            let postBody = try JSONSerialization.data(withJSONObject: self.rawValue)
            return postBody
        } catch {
            LogError("TPUploadable.postBodyData() unable to serialize \(self)!")
            return nil
        }
    }
    
    // Used by API to extend baseurl for a post request
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/v1/users/" + userId + "/data_sets"
        return urlExtension
    }

    //
    // MARK: - Fetchable
    //
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        var dataset: TPDataset? = nil
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data)
            if let dict = object as? [String: Any] {
                LogInfo("parsing \(dict)")
                if let jsonDict = dict["data"] as? [String: Any]{
                    dataset = TPDataset(rawValue: jsonDict)
                }
            } else {
                LogError("Received data not json decodable!")
            }
        } catch (let error) {
            LogError("Received data not json decodable: \(error)")
        }
        return dataset
    }
    
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
