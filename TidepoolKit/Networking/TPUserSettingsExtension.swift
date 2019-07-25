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
 
    class func urlPath(forUser userId: String) -> String {
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
