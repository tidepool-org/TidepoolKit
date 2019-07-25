//
//  TPUserProfile.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TPUserProfile: TPUserData, RawRepresentable {
    
    public let fullName: String?
    public let patient: TPUserPatient?

    // MARK: - RawRepresentable
    
    required public init?(rawValue: RawValue) {
        self.fullName = rawValue["fullName"] as? String
        self.patient = TPUserPatient.getSelfFromDict(rawValue)
    }
    
    public override var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        rawValue["fullName"] = fullName
        patient?.addSelfToDict(&rawValue)
        return rawValue
    }
}

