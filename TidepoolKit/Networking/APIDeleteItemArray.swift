//
//  APIDeleteItemArray.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

class APIDeleteItemArray: TPUploadable {
    
    var deleteData: [TPDeleteItem]

    // init changes TPDataItems into basic TPDeviceData items so that the upload machinery works...
    init(_ deleteArray: [TPDeleteItem]) {
        self.deleteData = deleteArray
    }
    
    //
    // MARK: - TPUploadable
    //
   
    func postBodyData() -> Data? {
        return postBodyData(deleteData)
    }

    func parseErrResponse(_ response: Data) -> [Int]? {
        // error response doesn't contain array of items that could not be deleted!
        return nil
    }
    
}
