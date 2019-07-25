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

/// This object is returned by the login call, so is atypical (no fetch required). Also, it needs to be re-created from persisted data for logged in users on app restart.
public class APIUser: Codable {
    
    public let userId: String
    public let emailVerified: Bool?
    public let emails: [String]?
    public let userName: String?
    public let termsAccepted: Date?

    public var debugDescription: String {
        get {
            var result = "user: \(userId)"
            if let emailVerified = emailVerified {
                result = result + "\nemailVerified: " + String(emailVerified)
            }
            if let emails = emails {
                for email in emails {
                    result = result + "\nemail: " + email
                }
            }
            if let userName = userName {
                result = result + "\nuserName: \(userName)"
            }
            if let termsAccepted = termsAccepted {
                result = result + "\ntermsAccepted: \(termsAccepted)"
            }
            return result
        }
    }

    //
    // MARK: - Framework private methods
    //
    
    init(_ userId: String, userName: String?) {
        self.userId = userId
        self.userName = userName
        self.emailVerified = nil
        self.emails = nil
        self.termsAccepted = nil
    }
    
    class func fromJsonData(_ data: Data) -> APIUser? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            let decodedUser = try decoder.decode(APIUser.self, from: data)
            return decodedUser
        } catch {
            return nil
        }
    }
    
    func toJsonData(forPrint: Bool = false) -> Data? {
        let encoder = JSONEncoder()
        if forPrint {
            encoder.outputFormatting = .prettyPrinted
        }
        encoder.dateEncodingStrategy = .iso8601
        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        // use standard camel-casing for our object
        case userId = "userid"
        case userName = "username"
        // json keys for these are the same as our object...
        case emailVerified
        case emails
        case termsAccepted
    }
    
}

/*
 Example service json:
 
    let jsonUser = """
    {
        "userid" : "e451301728",
        "emailVerified" : true,
        "emails" : [
        "johannah@gmail.com"
        ],
        "username" : "johannah@gmail.com",
        "termsAccepted" : "2018-03-01T13:07:03-08:00"
    }
    """.data(using: .utf8)!

 */
