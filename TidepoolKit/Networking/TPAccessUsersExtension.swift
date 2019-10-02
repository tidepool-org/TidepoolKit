//
//  TPAccessUsersExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension TPAccessUsers: TPFetchable {
    
    class func urlPath(forUser userId: String) -> String {
        let urlExtension = "/access/groups/" + userId
        return urlExtension
    }
    
    class func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
            return nil
        }
        var users: [TPUser] = []
        for key in jsonDict.keyEnumerator() {
            if let userId = key as? String {
                let user = TPUser(userId)
                users.append(user)
            }
        }
        return TPAccessUsers(users)
    }
}

