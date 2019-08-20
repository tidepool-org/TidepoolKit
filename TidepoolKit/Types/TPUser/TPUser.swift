/*
 * Copyright (c) 2019, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */

import Foundation

/// The APIConnect interface holds an object of this type, constructed initially with data from the login call, and re-created from persisted data for logged in users on app restart. It is augmented with data from service profile and settings information that can be updated occasionally.
/// For other users, this object may be constructed with information from ???
public class TPUser {
    
    // fields from user login...
    public let userId: String
    public let emailVerified: Bool?
    public let emails: [String]?  // don't expose..
    public let userName: String?  // email...
    public let termsAccepted: Date?
        
    public var debugDescription: String {
        get {
            var result = "user: \(userId)"
            if let emailVerified = emailVerified {
                result = result + "\n emailVerified: " + String(emailVerified)
            }
            if let emails = emails {
                for email in emails {
                    result = result + "\n email: " + email
                }
            }
            if let userName = userName {
                result = result + "\n userName: \(userName)"
            }
            if let termsAccepted = termsAccepted {
                result = result + "\n termsAccepted: \(termsAccepted)"
            }
            return result
        }
    }

    //
    // MARK: - Framework private methods
    //
    
    /// Creates a TPUser from persistent data (eventually Core Data?)
    init(_ userId: String, userName: String?) {
        self.userId = userId
        self.userName = userName
        self.emailVerified = nil
        self.emails = nil
        self.termsAccepted = nil
    }
    
    init(_ logInUser: APIUser) {
        self.userId = logInUser.userId
        self.userName = logInUser.userName
        self.emailVerified = logInUser.emailVerified
        self.emails = logInUser.emails
        self.termsAccepted = logInUser.termsAccepted
    }    
}

