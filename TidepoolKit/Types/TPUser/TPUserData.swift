//
//  TPUserData.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPUserData: CustomStringConvertible {
    
    // CustomStringConvertible conformance

    public var description: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }

    // MARK: - RawRepresentable

    public typealias RawValue = [String: Any]
    
    // override!
    public var rawValue: RawValue {
        fatalError()
    }

}

