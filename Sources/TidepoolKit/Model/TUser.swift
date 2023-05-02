//
//  TUser.swift
//  TidepoolKit
//
//  Created by Pete Schwamb on 4/15/23.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation

public struct TUser: Codable, Equatable {
    public var emailVerified: Bool
    public var emails: [String]
    public var roles: [String]
    public var termsAccepted: Date
    public var userid: String
    public var username: String
}
