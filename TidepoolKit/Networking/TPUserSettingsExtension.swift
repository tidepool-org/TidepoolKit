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

/// This is a service-aligned class, Codable. It is private to the framework.
extension TPUserSettings: TPFetchable {
 
    //
    // MARK: - methods private to framework!
    //

    class func settingsFromJsonData(_ data: Data) -> TPUserSettings? {
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data)
            if let jsonDict = object as? [String: Any] {
                return TPUserSettings(rawValue: jsonDict)
            } else {
                LogError("\(#function) Profile data not json decodable!")
            }
        } catch (let error) {
            LogError("\(#function) Profile data not json decodable: \(error)")
        }
        return nil
    }

    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/metadata/" + userId + "/settings"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        return TPUserSettings.settingsFromJsonData(data)
    }

}

/*
 Example service json:
 
    let jsonSettings = """
    {
        "bgTarget" : {
            "low" : 80,
            "high" : 165
        },
        "units" : {
            "bg" : "mg/dL"
        }
    }
    """.data(using: .utf8)!

    let jsonSettingsAlt = """
    {
        "units" : {
            "bg" : "mmol/L"
        },
        "bgTarget" : {
            "low" : 4.4000000000000004,
            "high" : 9.1999999999999993
        }
    }
    """.data(using: .utf8)!

 */
