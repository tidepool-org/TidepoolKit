//
//  APIAccessUsers.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class APIAccessUsers: TPFetchable {
    
    public let users: [TPUser]
        
    //
    // MARK: - methods private to framework!
    //

    init(_ users: [TPUser]) {
        self.users = users
    }

    class func accessUsersFromJsonData(_ data: Data) -> APIAccessUsers? {
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                var users: [TPUser] = []
                for key in jsonDict.keyEnumerator() {
                    if let keyStr = key as? String {
                        let user = TPUser(keyStr)
                        users.append(user)
                        print("adding user: \(user)")
                    }
                }
                return APIAccessUsers(users)
            }
        } catch {
        }
        return nil
    }

    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/access/groups/" + userId
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        return APIAccessUsers.accessUsersFromJsonData(data)
    }
}


/*
 Example service json:

    let jsonAccessGroups = """
    {
        "f934a287c4" : {
            "root":{}
        },
        "739993beb3" : {
            "note":{},
            "view":{}
        },
        "3ee821ad6b" : {
            "note":{},
            "view":{}
        }
    }
    """.data(using: .utf8)!

 */
