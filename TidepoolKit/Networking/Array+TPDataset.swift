//
//  Array+TPDataset.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Used internally...
extension Array: TPFetchable where Element == TPDataset {

    static func urlPath(forUser userId: String) -> String {
        let urlExtension = "/v1/users/" + userId + "/data_sets?client.name=org.tidepool.mobile&size=1"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDictArray = dictArrayFromJsonData(data) else {
            return nil
        }
        var items: [TPDataset] = []
        for jsonDict in jsonDictArray {
            LogInfo("calling createFromJson on \(jsonDict)")
            if let item = TPDataset(rawValue: jsonDict) {
                items.append(item)
            }
        }
        return items
    }

}
