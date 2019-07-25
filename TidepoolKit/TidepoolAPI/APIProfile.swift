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

public class APIProfile: Codable, TPFetchable {
    
    public let fullName: String?

    public struct Patient: Codable {
        let biologicalSex: String?
        let birthday: String?
        let diagnosisDate: String?
        let diagnosisType: String?
    }
    
    public let patient: Patient?

    public var debugDescription: String {
        get {
            var result = "Profile:"
            if let fullName = fullName {
                result = result + "\nfullName: " + fullName
            }
            if let patient = patient {
                result = result + "\npatient:"
                if let biologicalSex = patient.biologicalSex {
                    result = result + "\n biologicalSex: " + biologicalSex
                }
                if let diagnosisDate = patient.diagnosisDate {
                    result = result + "\n diagnosisDate: " + diagnosisDate
                }
                if let diagnosisType = patient.diagnosisType {
                    result = result + "\n diagnosisType: " + diagnosisType
                }
                if let birthday = patient.birthday {
                    result = result + "\n birthday: " + birthday
                }
            }
            return result
        }
    }

    //
    // MARK: - methods private to framework!
    //

    class func profileFromJsonData(_ data: Data) -> APIProfile? {
        return jsonToObject(data)
    }
    
    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/metadata/" + userId + "/profile"
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        return APIProfile.profileFromJsonData(data)
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
