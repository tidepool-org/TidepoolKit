//
//  TPUser.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/20/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Login will return a TPUser in the TPSession object. 
public class TPUser: TPUserData, RawRepresentable {
    
    // fields from user login...
    public let userId: String
    public let userName: String?  // email...
    
    public init(_ userId: String, userName: String? = nil) {
        self.userId = userId
        self.userName = userName
    }
    
    //
    // MARK: - RawRepresentable
    //
    
    public required init?(rawValue: [String : Any]) {
        guard let userId = rawValue["userid"] as? String else {
            return nil
        }
        self.userName = rawValue["username"] as? String
        self.userId = userId
     }
    
    public override var rawValue: [String : Any] {
        var result = [String: Any]()
        result["userId"] = userId as Any
        result["userName"] = userName as Any
        return result
    }

    //
    // MARK: - Framework private methods
    //
    
    class func fromJsonData(_ data: Data) -> TPUser? {
        guard let json: Any = try? JSONSerialization.jsonObject(with: data) else {
            LogError("Fetched data not json decodable!")
            return nil
        }
        
        guard let jsonDict = json as? [String: Any] else {
            LogError("Fetched json not a [String: Any]: \(json)!")
            return nil
        }
        
        return TPUser(rawValue: jsonDict)        
    }

}

