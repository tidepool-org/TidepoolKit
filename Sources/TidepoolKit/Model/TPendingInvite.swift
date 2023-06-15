//
//  TPendingInvite.swift
//  TidepoolKit
//
//  Created by Arwain Karlin on 6/5/23.
//

import Foundation

public struct TPendingInvite: Codable, Equatable {
    public let key: String
    public let type: String
    public let status: String
    public let email: String
    public let creatorId: String
    public let created: Date
    public let modified: Date
    public let creator: TCreator
//    public let context: String
//    public let restrictions: TRestrictions
    
    init(key: String, type: String, status: String, email: String, creatorId: String, created: Date, modified: Date, creator: TCreator) {
        self.key = key
        self.type = type
        self.status = status
        self.email = email
        self.creatorId = creatorId
        self.created = created
        self.modified = modified
        self.creator = creator
    }
}
