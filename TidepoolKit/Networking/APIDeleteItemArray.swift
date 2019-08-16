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

/// Subclass of APIDeleteItemArray used for deleting items.
class APIDeleteItemArray: APIDeviceDataArray {
    
    init(_ userData: [TPDeleteItem]) {
        super.init(userData)
    }

    // convenience init for turning any APIDeviceDataArray into a APIDeleteItemArray
    init(_ userData: APIDeviceDataArray) {
        var deleteArray: [TPDeleteItem] = []
        for item in userData.userData {
            if let deleteItem = TPDeleteItem(item) {
                deleteArray.append(deleteItem)
            } else {
                LogError("APIDeviceDataArray item \(item.debugDescription) has no id or origin id, unable to delete!")
            }
        }
        super.init(deleteArray)
    }

}
