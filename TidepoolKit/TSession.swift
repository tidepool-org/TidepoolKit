//
//  TSession.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/17/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

/// Representation of a Tidepool API session, including the environment, an authentication token, and a user ID.
public struct TSession {

    // The environment used for authentication and for any future API network requests.
    public let environment: TEnvironment

    // The authentication token returned via authentication and for use with any future API network requests.
    public let authenticationToken: String

    // The user ID associated with the authentication token required by some API network requests.
    public let userID: String
    
    public init(environment: TEnvironment, authenticationToken: String, userID: String) {
        self.environment = environment
        self.authenticationToken = authenticationToken
        self.userID = userID
    }
}

extension TSession: RawRepresentable {
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        guard let environmentRawValue = rawValue["environment"] as? TEnvironment.RawValue,
            let environment = TEnvironment(rawValue: environmentRawValue),
            let authenticationToken = rawValue["authenticationToken"] as? String,
            let userID = rawValue["userID"] as? String else
        {
            return nil
        }
        self.environment = environment
        self.authenticationToken = authenticationToken
        self.userID = userID
    }
    
    public var rawValue: RawValue {
        return [
            "environment": environment.rawValue,
            "authenticationToken": authenticationToken,
            "userID": userID
        ]
    }
}
