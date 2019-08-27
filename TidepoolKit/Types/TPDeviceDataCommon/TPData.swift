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

    //
    // MARK: - Utility methods for validating data fields in TPData structs
    //
    
    // ValidateDouble with Double result only returns a Double value if a non-nil value is passed in that in in-bounds of any max or min
    func validateDouble(_ value: Double?, min: Double? = nil, max: Double? = nil) -> Double? {
        var result: Double? = value
        guard let value = value else {
            return nil
        }
        if let min = min {
            if value < min {
                LogError("Err: value \(value) is less than minimum!")
                result = nil
            }
        }
        if let max = max {
            if value > max {
                LogError("Err: value \(value) is greater than maximum!")
                result = nil
            }
        }
        return result
    }
    
    // isValidDouble requires a non-nil value, or a value that is in-bounds of any max or min
    func isValidDouble(_ value: Double?, min: Double? = nil, max: Double? = nil) -> Bool {
        guard let value = value else {
            return false
        }
        if let min = min {
            if value < min {
                LogError("Err: value \(value) is less than minimum!")
                return false
            }
        }
        if let max = max {
            if value > max {
                LogError("Err: value \(value) is greater than maximum!")
                return false
            }
        }
        return true
    }
    
    func isValidDoubleOrNil(_ value: Double?, min: Double? = nil, max: Double? = nil) -> Bool {
        guard let value = value else {
            return true
        }
        return isValidDouble(value, min: min, max: max)
    }

    // Returns false if string is non-nil and length exceeds maxLen. If nil, or length is ok, returns true.
    func validateString(_ string: String?, maxLen: Int? = nil, notEmpty: Bool = false) -> Bool {
        if let string = string, let maxLen = maxLen {
            if string.lengthOfBytes(using: .utf8) > maxLen {
                LogError("Err: length of string \(string) is greater than max \(maxLen)!")
                return false
            }
            if notEmpty, string.isEmpty {
                LogError("Err: string is empty!")
                return false
            }
        }
        return true
    }

    var description: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
}

