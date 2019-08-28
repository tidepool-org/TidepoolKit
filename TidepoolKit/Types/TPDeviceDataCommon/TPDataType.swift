//
//  TPDataType.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum TPDataType: String, Codable {
    // sample types
    case cbg = "cbg"
    case food = "food"
    case basal = "basal"
    // common types
    case origin = "origin"
    case payload = "payload"
    case association = "association"
    case location = "location"
    // location related
    case latitude = "latitude"
    case longitude = "longitude"
    case verticalAccuracy = "verticalAccuracy"
    case horizontalAccuracy = "horizontalAccuracy"
    case elevation = "elevation"
    case gps = "gps"
    // food related
    case amount = "amount"
    case carbohydrate = "carbohydrate"
    case energy = "energy"
    case fat = "fat"
    case ingredient = "ingredient"
    case nutrition = "nutrition"
    case protein = "protein"
    // user types
    case patient = "patient"
    // requires override!
    case unsupported = "unsupported"
        
    public static func description(_ rawDict: [String: Any], linePrefix: String = "\n ") -> String {
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

