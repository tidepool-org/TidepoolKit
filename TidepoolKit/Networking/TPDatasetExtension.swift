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
    
    //
    // MARK: - Postable, Fetchable
    //

    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/v1/users/" + userId + "/data_sets"
        return urlExtension
    }

    //
    // MARK: - Fetchable
    //
    
    class func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let dict = dictFromJsonData(data) else {
            return nil
        }
        guard let jsonDict = dict["data"] as? [String: Any] else {
            LogError("no 'data' object in json dict \(dict)")
            return nil
        }
        return TPDataset(rawValue: jsonDict)
    }
    
}
