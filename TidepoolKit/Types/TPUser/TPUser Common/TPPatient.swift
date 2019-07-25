//
//  TPPatient.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/27/19.
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
        var rawValue: [String: Any] = [:]
        rawValue["biologicalSex"] = biologicalSex
        rawValue["birthday"] = birthday
        rawValue["diagnosisDate"] = diagnosisDate
        rawValue["diagnosisType"] = diagnosisType
        return rawValue
    }
}

