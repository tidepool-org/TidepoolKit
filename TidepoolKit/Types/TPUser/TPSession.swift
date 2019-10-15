//
//  TPSession.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/20/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Login will return a TPSession. It may be persisted by the client (as RawRepresentable), and used again.
public class TPSession: TPUserData, RawRepresentable {
    
    public let authenticationToken: String
    public let user: TPUser
    public let serverHost: String
    
    init(_ token: String, user: TPUser, serverHost: String) {
        self.authenticationToken = token
        self.user = user
        self.serverHost = serverHost
        super.init()
    }
    
    public var baseUrlString: String { return "https://" + serverHost }

    // MARK: - RawRepresentable

    public required init?(rawValue: [String : Any]) {
        guard let token = rawValue["authenticationToken"] as? String else {
            LogError("TPSession rawValue is missing auth token!")
            return nil
        }
        guard let serverHost = rawValue["serverHost"] as? String else {
            LogError("TPSession rawValue is missing serverHost string!")
            return nil
        }
        guard let userRaw = rawValue["user"] as? [String: Any] else {
            LogError("TPSession rawValue is missing user dict!")
            return nil
        }
        guard let user = TPUser(rawValue: userRaw) else {
            LogError("TPSession rawValue is missing valid user!")
            return nil
        }
        self.authenticationToken = token
        self.serverHost = serverHost
        self.user = user
    }
    
    public override var rawValue: [String : Any] {
        var result = [String: Any]()
        result["authenticationToken"] = authenticationToken
        result["user"] = user.rawValue
        result["serverHost"] = serverHost
        return result
    }

}
