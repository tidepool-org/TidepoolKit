//
//  TPUserProfile.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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

public class TPUserProfile: TPUserData, RawRepresentable {
    
    public let fullName: String?
    public let patient: TPUserPatient?

    // MARK: - RawRepresentable
    
    required public init?(rawValue: RawValue) {
        self.fullName = rawValue["fullName"] as? String
        self.patient = TPUserPatient.getSelfFromDict(rawValue)
    }
    
    public override var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["fullName"] = fullName as Any
        patient?.addSelfToDict(&resultDict)
        return resultDict
    }
}

