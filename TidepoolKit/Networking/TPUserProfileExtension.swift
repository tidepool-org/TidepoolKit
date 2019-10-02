//
//  TPUserProfileExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension TPUserProfile: TPFetchable {
    
    class func urlPath(forUser userId: String) -> String {
        let urlExtension = "/metadata/" + userId + "/profile"
        return urlExtension
    }
    
    class func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDict = dictFromJsonData(data) else {
            return nil
        }
        return TPUserProfile(rawValue: jsonDict)
    }

}

