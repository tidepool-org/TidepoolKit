//
//  TPDatasetArray.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 10/2/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Class used internally for fetching/uploading device data...
class TPDatasetArray {
    
    var datasets: [TPDataset]

    init(_ datasets: [TPDataset]) {
        self.datasets = datasets
    }
}

extension TPDatasetArray: TPFetchable {
    
    static func urlPath(forUser userId: String) -> String {
        let urlExtension = "/v1/users/" + userId + "/data_sets?client.name=org.tidepool.mobile&size=1"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDictArray = dictArrayFromJsonData(data) else {
            return nil
        }
        var datasets: [TPDataset] = []
        for jsonDict in jsonDictArray {
            if let item = TPDataset(rawValue: jsonDict) {
                datasets.append(item)
            }
        }
        return TPDatasetArray(datasets)
    }

}
