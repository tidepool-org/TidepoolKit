//
//  LoginResponse.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/20/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

struct LoginResponse: RawRepresentable {
    typealias RawValue = [String: Any]

    let userID: String
    let email: String
    let emailVerified: Bool
    let termsAccepted: String?

    init?(rawValue: RawValue) {
        guard let userID = rawValue["userid"] as? String,
            let email = rawValue["username"] as? String,
            let emailVerified = rawValue["emailVerified"] as? Bool else
        {
            return nil
        }

        self.userID = userID
        self.email = email
        self.emailVerified = emailVerified
        self.termsAccepted = rawValue["termsAccepted"] as? String
    }

    var rawValue: RawValue {
        fatalError("rawValue has not been implemented")
    }
}
