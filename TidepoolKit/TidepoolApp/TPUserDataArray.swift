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

/// Simple array containing mixed data types.
public class TPUserDataArray {
    
    var userData: [TPData]
    let forDelete: Bool

    public init(_ userData: [TPData], forDelete: Bool = false) {
        self.userData = userData
        self.forDelete = forDelete
    }
    
    public var debugDescription: String {
        get {
            var result = "TPUserDataArray \(userData.count) items:"
            for item in userData {
                result += "\n" + item.debugDescription
            }
            return result
        }
    }
    
}
