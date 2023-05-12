//
//  TInvite.swift
//  TidepoolKit
//
//  Created by Pete Schwamb on 5/11/23.
//

import Foundation

public struct TPermissionFlag: Codable {
    public init() {}
}

public struct TInvitePermissions: Codable {
    let note: TPermissionFlag?
    let upload: TPermissionFlag?
    let view: TPermissionFlag?

    public init(note: TPermissionFlag? = nil, upload: TPermissionFlag? = nil, view: TPermissionFlag? = nil) {
        self.note = note
        self.upload = upload
        self.view = view
    }
}

public struct TInviteRequest: Codable {
    let email: String
    let permissions: TInvitePermissions

    public init(email: String, permissions: TInvitePermissions) {
        self.email = email
        self.permissions = permissions
    }
}

public struct TInvite: Codable {
    let key: String
    let type: String
    let email: String
    let creatorId: String
    let created: Date
    let modified: Date
    // let creator: TCreator
    let status: String
}

