//
//  TPAccessUsersExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension TPAccessUsers: TPFetchable {
    
    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/access/groups/" + userId
        return urlExtension
    }
    
    class func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
            return nil
        }
        var users: [TPUser] = []
        for key in jsonDict.keyEnumerator() {
            if let keyStr = key as? String {
                let user = TPUser(keyStr)
                users.append(user)
                print("adding user: \(user)")
            }
        }
        return TPAccessUsers(users)
    }
}

