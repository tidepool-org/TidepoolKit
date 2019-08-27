//
//  TPUserProfileExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension TPUserProfile: TPFetchable {
    
    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/metadata/" + userId + "/profile"
        return urlExtension
    }
    
    class func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDict = dictFromJsonData(data) else {
            return nil
        }
        return TPUserProfile(rawValue: jsonDict)
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
