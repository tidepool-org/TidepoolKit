//
//  Array+TPDeleteItem.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension Array: TPUploadable where Element == TPDeleteItem {

    func postBodyData() -> Data? {
        return self.postBodyData(self)
    }

    func parseErrResponse(_ response: Data) -> [Int]? {
        // error response doesn't contain array of items that could not be deleted!
        return nil
    }
    
}
