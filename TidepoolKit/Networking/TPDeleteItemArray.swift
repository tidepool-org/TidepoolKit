//
//  TPDeleteItemArray.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 10/2/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

// Note: An alternate approach would be to extend Array to support TPUploadable when the array element type is a TPDeleteItem. However, this can only be done for a single type, so would be a one-off.

class TPDeleteItemArray {
    
    var deleteData: [TPDeleteItem]
    
    init(_ deleteArray: [TPDeleteItem]) {
        self.deleteData = deleteArray
    }
}

extension TPDeleteItemArray: TPUploadable {
    
    func postBodyData() -> Data? {
        return postBodyData(deleteData)
    }
    
    func parseErrResponse(_ response: Data) -> [Int]? {
        return nil  // nothing interesting in the response
    }
    
}
