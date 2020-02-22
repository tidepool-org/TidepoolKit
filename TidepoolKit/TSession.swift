//
//  TSession.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/17/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation

/// Representation of a Tidepool API session, including the environment, an authentication token, and a user id.
public struct TSession: Codable, Equatable {

    // The environment used for authentication and for any future API network requests.
    public let environment: TEnvironment

    // The authentication token returned via authentication and for use with any future API network requests.
    public let authenticationToken: String

    // The user id associated with the authentication token required by some API network requests.
    public let userId: String

    // The value of the optional X-Tidepool-Trace-Session header added to any future API network requests. The default UUID string
    // is usually sufficient, but can be changed or removed.
    public var trace: String?
    
    public init(environment: TEnvironment, authenticationToken: String, userId: String, trace: String? = UUID().uuidString) {
        self.environment = environment
        self.authenticationToken = authenticationToken
        self.userId = userId
        self.trace = trace
    }
}
