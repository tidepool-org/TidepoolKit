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
class APIUserSettings: Codable, TPFetchable {
 
    struct BGUnits: Codable {
        let bg: String
    }

    struct BGTarget: Codable {
        let low: Double
        let high: Double
    }

    let units: BGUnits?
    let bgTarget: BGTarget?

    var debugDescription: String {
        get {
            var result = "userSettingsService:"
            if let units = units {
                result = result + "\nunits: \(units.bg)"
            }
            if let bgTarget = bgTarget {
                result = result + "\nbgTargetHigh: \(bgTarget.high)"
                result = result + "\nbgTargetLow: \(bgTarget.low)"
            }
            return result
        }
    }
    
    //
    // MARK: - methods private to framework!
    //

    class func settingsFromJsonData(_ data: Data) -> APIUserSettings? {
        return jsonToObject(data)
    }

    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/metadata/" + userId + "/settings"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        return APIUserSettings.settingsFromJsonData(data)
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
