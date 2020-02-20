//
//  TSession.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/17/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation

/// Representation of a Tidepool API session, including the environment, an authentication token, and a user ID.
public struct TSession: RawRepresentable {
    public typealias RawValue = [String: Any]

    // The environment used for authentication and for any future API network requests.
    public let environment: TEnvironment

    // The authentication token returned via authentication and for use with any future API network requests.
    public let authenticationToken: String

    // The user ID associated with the authentication token required by some API network requests.
    public let userID: String

    // The value of the optional X-Tidepool-Trace-Session header added to any future API network requests. The default UUID string
    // is usually sufficient, but can be changed or removed.
    public var trace: String?
    
    public init(environment: TEnvironment, authenticationToken: String, userID: String, trace: String? = UUID().uuidString) {
        self.environment = environment
        self.authenticationToken = authenticationToken
        self.userID = userID
        self.trace = trace
    }

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
        self.trace = rawValue["trace"] as? String
    }
    
    public var rawValue: RawValue {
        var rawValue: RawValue = [:]
        rawValue["environment"] = environment.rawValue
        rawValue["authenticationToken"] = authenticationToken
        rawValue["userID"] = userID
        rawValue["trace"] = trace
        return rawValue
    }
}
