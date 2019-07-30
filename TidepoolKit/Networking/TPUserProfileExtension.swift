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

extension TPUserProfile: TPFetchable {
    
    class func profileFromJsonData(_ data: Data) -> TPUserProfile? {
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data)
            if let jsonDict = object as? [String: Any] {
                return TPUserProfile(rawValue: jsonDict)
            } else {
                LogError("\(#function) Profile data not json decodable!")
            }
        } catch (let error) {
            LogError("\(#function) Profile data not json decodable: \(error)")
        }
        return nil
    }


    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/metadata/" + userId + "/profile"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        return TPUserProfile.profileFromJsonData(data)
    }
    

}

/*
 Example service json:

    let jsonProfile = """
    {
        "patient" : {
        "biologicalSex" : "female",
        "birthday" : "1983-08-27",
        "diagnosisDate" : "1983-08-27",
        "diagnosisType" : "prediabetes"
        },
        "fullName" : "Johannah Tsui"
    }
    """.data(using: .utf8)!

 */
