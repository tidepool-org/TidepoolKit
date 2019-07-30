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

public struct TPUserPatient: TPData {
    public static var tpType: TPDataType { return .patient }

    public let biologicalSex: String?
    public let birthday: String?
    public let diagnosisDate: String?
    public let diagnosisType: String?
    
    // TODO: is an init necessary? Typically read-only
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        self.biologicalSex = rawValue["biologicalSex"] as? String
        self.birthday = rawValue["birthday"] as? String
        self.diagnosisDate = rawValue["diagnosisDate"] as? String
        self.diagnosisType = rawValue["diagnosisType"] as? String
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["biologicalSex"] = self.biologicalSex as Any
        resultDict["birthday"] = self.birthday as Any
        resultDict["diagnosisDate"] = self.diagnosisDate as Any
        resultDict["diagnosisType"] = self.diagnosisType as Any
        return resultDict
    }
}

public class TPUserProfile: RawRepresentable {
    
    public let fullName: String?
    public let patient: TPUserPatient?

    public var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }

    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    required public init?(rawValue: RawValue) {
        self.fullName = rawValue["fullName"] as? String
        self.patient = TPDataType.getTypeFromDict(TPUserPatient.self, rawValue)
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["fullName"] = fullName as Any
        patient?.addSelfToDict(&resultDict)
        return resultDict
    }
}

