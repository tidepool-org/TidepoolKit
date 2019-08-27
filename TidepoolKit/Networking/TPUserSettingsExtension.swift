//
//  TPUserSettingsExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// This is a service-aligned class, Codable. It is private to the framework.
extension TPUserSettings: TPFetchable {
 
    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/metadata/" + userId + "/settings"
        return urlExtension
    }
    
    class func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDict = dictFromJsonData(data) else {
            return nil
        }
        return TPUserSettings(rawValue: jsonDict)
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
