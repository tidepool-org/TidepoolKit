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
