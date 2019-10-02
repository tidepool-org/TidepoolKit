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
    public let server: TidepoolServer
    
    init(_ token: String, user: TPUser, server: TidepoolServer) {
        self.authenticationToken = token
        self.user = user
        self.server = server
        super.init()
    }

    // MARK: - RawRepresentable

    public required init?(rawValue: [String : Any]) {
        guard let token = rawValue["authenticationToken"] as? String else {
            LogError("TPSession rawValue is missing auth token!")
            return nil
        }
        guard let serverString = rawValue["server"] as? String else {
            LogError("TPSession rawValue is missing server string!")
            return nil
        }
        guard let server = TidepoolServer(rawValue: serverString) else {
            LogError("TPSession server string is invalid!")
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
        self.server = server
        self.user = user
    }
    
    public override var rawValue: [String : Any] {
        var result = [String: Any]()
        result["authenticationToken"] = authenticationToken
        result["user"] = user.rawValue
        result["server"] = server.rawValue
        return result
    }

}
