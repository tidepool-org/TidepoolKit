//
//  TPUserProfileExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension TPUserProfile: TPFetchable {
    
    class func profileFromJsonData(_ data: Data) -> TPUserProfile? {
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data)
            if let jsonDict = object as? [String: Any] {
                return TPUserProfile(rawValue: jsonDict)
            } else {
                LogError("Profile data not json decodable!")
            }
        } catch (let error) {
            LogError("Profile data not json decodable: \(error)")
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
