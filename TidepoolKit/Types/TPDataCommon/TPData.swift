//
//  TPData.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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

    var description: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }

}

