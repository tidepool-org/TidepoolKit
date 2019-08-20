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

public protocol TPData: RawRepresentable where RawValue == [String : Any] {
    static var tpType: TPDataType { get }
}

public extension TPData {
    static var typeName: String {
        get {
            return tpType.rawValue
        }
    }
    
    func addSelfToDict(_ dict: inout [String: Any]) {
        dict[type(of: self).typeName] = self.rawValue
    }
    
    static func getSelfFromDict<T: TPData>(_ dict: [String: Any]) -> T? {
        if let typeDict = dict[T.typeName] as? [String: Any] {
            if let item = T.init(rawValue: typeDict) {
                return item
            }
        }
        return nil
    }

    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }

}

