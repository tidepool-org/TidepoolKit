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

public enum BGUnitType: String {
    case mmPerL = "mmol/L"  // should match service json values!
    case mgPerDl = "mg/dL"  // should match service json values!
}

/// The APIConnect interface holds an object of this type, constructed initially with data from the login call, and re-created from persisted data for logged in users on app restart. It is augmented with data from service profile and settings information that can be updated occasionally.
/// For other users, this object may be constructed with information from ???
public class TPUser {
    
    // fields from user login...
    public let userId: String
    public let emailVerified: Bool?
    public let emails: [String]?  // don't expose..
    public let userName: String?  // email...
    public let termsAccepted: Date?
    
    // fields from user settings...
    public var displayUnitType: BGUnitType = .mgPerDl
    // targets always stored in mmPerL
    public var bgTargetLow: Int = TPKitConstants.BgLowDefault
    public var bgTargetHigh: Int = TPKitConstants.BgHighDefault
    public var configuredFromService: Bool = false
    public var mMolPerLiterDisplay: Bool {
        return displayUnitType == .mmPerL
    }
    // nil until first update...
    public var lastSettingsUpdate: Date? = nil
    
    // fields from user profile...
    public var fullName: String?
    public var biologicalSex: String?
    public var birthday: String?
    public var diagnosisDate: String?
    public var diagnosisType: String?
    public var lastProfileUpdate: Date? = nil

    // other fields tbd...
    //var uploadId: String?
    
    public var debugDescription: String {
        get {
            var result = "user: \(userId)"
            if let emailVerified = emailVerified {
                result = result + "\n emailVerified: " + String(emailVerified)
            }
            if let emails = emails {
                for email in emails {
                    result = result + "\n email: " + email
                }
            }
            if let userName = userName {
                result = result + "\n userName: \(userName)"
            }
            if let termsAccepted = termsAccepted {
                result = result + "\n termsAccepted: \(termsAccepted)"
            }
            if lastSettingsUpdate == nil {
                result = result + "\nuserSettings: default (not configured)"
            } else {
                result = result + "\nuserSettings:"
                result = result + "\n bgLow: \(bgTargetLow)mgPerDl"
                result = result + "\n bgHigh: \(bgTargetHigh)mgPerDl"
                result = result + "\n display units: \(displayUnitType.rawValue)"
            }
            if lastProfileUpdate == nil {
                result = result + "\nuserProfile: default (not configured)"
            } else {
                result = result + "\nuserProfile:"
                if let fullName = fullName {
                    result = result + "\nfullName: " + fullName
                }
                if let biologicalSex = biologicalSex {
                    result = result + "\n biologicalSex: " + biologicalSex
                }
                if let diagnosisDate = diagnosisDate {
                    result = result + "\n diagnosisDate: " + diagnosisDate
                }
                if let diagnosisType = diagnosisType {
                    result = result + "\n diagnosisType: " + diagnosisType
                }
                if let birthday = birthday {
                    result = result + "\n birthday: " + birthday
                }
            }
            return result
        }
    }

    //
    // MARK: - Framework private methods
    //
    
    /// Creates a TPUser from persistent data (eventually Core Data?)
    init(_ userId: String, userName: String?) {
        self.userId = userId
        self.userName = userName
        self.emailVerified = nil
        self.emails = nil
        self.termsAccepted = nil
    }
    
    init(_ logInUser: APIUser) {
        self.userId = logInUser.userId
        self.userName = logInUser.userName
        self.emailVerified = logInUser.emailVerified
        self.emails = logInUser.emails
        self.termsAccepted = logInUser.termsAccepted
    }
    
    func updateWithProfileInfo(_ profile: APIProfile) {
        self.fullName = profile.fullName
        self.biologicalSex = profile.patient?.biologicalSex
        self.birthday = profile.patient?.birthday
        self.diagnosisDate = profile.patient?.diagnosisDate
        self.diagnosisType = profile.patient?.diagnosisType
        self.lastProfileUpdate = Date()
    }
    
    func updateWithUserSettings(_ settings: APIUserSettings) {
        // if no units are specified, assume mgPerDl
        self.displayUnitType = .mgPerDl
        if let units = settings.units {
            if units.bg == BGUnitType.mmPerL.rawValue {
                // this controls the display units, as well as interpretation of target data
                displayUnitType = .mmPerL
            }
        }
        guard let bgTarget = settings.bgTarget else {
            return
        }
        if displayUnitType == .mgPerDl {
            bgTargetLow = Int(bgTarget.low)
            bgTargetHigh = Int(bgTarget.high)
        } else {
            let conversionFactor = TPKitConstants.BgConvertToMgDl
            bgTargetLow = Int((bgTarget.low * conversionFactor) + 0.5)
            bgTargetHigh = Int((bgTarget.high * conversionFactor) + 0.5)
        }
        self.lastSettingsUpdate = Date()
    }
    
}

