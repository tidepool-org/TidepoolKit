//
//  TTrusteeUser.swift
//  
//
//  Created by Pete Schwamb on 3/27/23.
//

public struct TTrusteeUser: Codable, Equatable {
    public var emailVerified: Bool
    public var emails: [String]
    public var userid: String
    public var profile: TProfile?
    public var trustorPermissions: TPermissions?
    public var trusteePermissions: TPermissions?

    init(emailVerified: Bool, emails: [String], userid: String, profile: TProfile? = nil, trustorPermissions: TPermissions? = nil, trusteePermissions: TPermissions? = nil) {
        self.emailVerified = emailVerified
        self.emails = emails
        self.userid = userid
        self.profile = profile
        self.trustorPermissions = trustorPermissions
        self.trusteePermissions = trusteePermissions
    }
}
