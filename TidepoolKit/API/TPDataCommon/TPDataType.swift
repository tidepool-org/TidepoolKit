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

public enum TPDataType: String, Codable {
    // sample types
    case cbg = "cbg"
    case food = "food"
    case basal = "basal"
    // common types
    case amount = "amount"
    case association = "association"
    case carbohydrate = "carbohydrate"
    case energy = "energy"
    case fat = "fat"
    case ingredient = "ingredient"
    case location = "location"
    case nutrition = "nutrition"
    case origin = "origin"
    case payload = "payload"
    case protein = "protein"
    // user types
    case patient = "patient"
    // requires override!
    case unsupported = "unsupported"
    
    //
    // MARK: - Utility methods for validating data fields in TPDataType structs
    //
    // Note: Not sure the best place for these, can't go into a protocol, but nice to have them in a namespace. This enum provides that, although the methods don't really use the enum value...
    
    // ValidateDouble with Double result only returns a Double value if a non-nil value is passed in that in in-bounds of any max or min
    static func validateDouble(_ value: Double?, min: Double? = nil, max: Double? = nil) -> Double? {
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
    static func isValidDouble(_ value: Double?, min: Double? = nil, max: Double? = nil) -> Bool {
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
    
    static func isValidDoubleOrNil(_ value: Double?, min: Double? = nil, max: Double? = nil) -> Bool {
        guard let value = value else {
            return true
        }
        return isValidDouble(value, min: min, max: max)
    }
    
    // Returns false if string is non-nil and length exceeds maxLen. If nil, or length is ok, returns true.
    static func validateString(_ string: String?, maxLen: Int? = nil) -> Bool {
        if let string = string, let maxLen = maxLen {
            if string.lengthOfBytes(using: .utf8) > maxLen {
                LogError("Err: length of string \(string) is greater than max \(maxLen)!")
                return false
            }
        }
        return true
    }

    static func getTypeFromDict<T: TPData>(_ type: T.Type, _ dict: [String: Any]) -> T? {
        if let typeDict = dict[T.tpType.rawValue] as? [String: Any] {
            if let item = T.init(rawValue: typeDict) {
                return item
            }
        }
        return nil
    }

    static func description(_ rawDict: [String: Any], linePrefix: String = "\n ") -> String {
        var result: String = ""
        for (key, value) in rawDict {
            if let valueDict = value as? [String: Any] {
                let indent = linePrefix + " "
                result += "\(linePrefix)\(key):"
                result += TPDataType.description(valueDict, linePrefix: indent)
            } else if let dictArray = value as? [Any] {
                result += "\(linePrefix)\(key): ["
                let linePrefix = linePrefix + " "
                for item in dictArray {
                    if let subDict = item as? [String: Any] {
                        result += "\(linePrefix)["
                        result +=  TPDataType.description(subDict, linePrefix: linePrefix + " ")
                        result += "]"
                   }
                }
                result += "\(linePrefix)]"
            } else {
                result += "\(linePrefix)\(key): \(value)"
            }
        }
        return result
    }

}

