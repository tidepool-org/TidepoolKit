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

public class APIAccessUsers: TPFetchable {
    
    public let userIds: [String]
    
    public var debugDescription: String {
        get {
            var result = "access group user ids:"
            for item in userIds {
                result = result + "\n \(item)"
            }
            return result
        }
    }
    
    //
    // MARK: - methods private to framework!
    //

    init(_ userIds: [String]) {
        self.userIds = userIds
    }

    class func accessUsersFromJsonData(_ data: Data) -> APIAccessUsers? {
        do {
            if let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                var users: [String] = []
                for key in jsonDict.keyEnumerator() {
                    if let keyStr = key as? String {
                        users.append(keyStr)
                        print("adding key: \(keyStr)")
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
