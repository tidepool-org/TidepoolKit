//
//  TPrescription.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 4/22/21.
//  Copyright © 2021 Tidepool Project. All rights reserved.
//

public struct TPrescription: Codable, Equatable {
    public var id: String?
    public var patientUserId: String?
    public var accessCode: String?
    public var state: State?
    public var latestRevision: Revision?
    public var expirationTime: Date?
    public var prescriberUserId: String?
    public var createdTime: Date?
    public var createdUserId: String?
    public var modifiedTime: Date?
    public var modifiedUserId: String?
    
    public init(id: String? = nil,
                patientUserId: String? = nil,
                accessCode: String? = nil,
                state: State? = nil,
                latestRevision: Revision? = nil,
                expirationTime: Date? = nil,
                prescriberUserId: String? = nil,
                createdTime: Date? = nil,
                createdUserId: String? = nil,
                modifiedTime: Date? = nil,
                modifiedUserId: String? = nil) {
        self.id = id
        self.patientUserId = patientUserId
        self.accessCode = accessCode
        self.state = state
        self.latestRevision = latestRevision
        self.expirationTime = expirationTime
        self.prescriberUserId = prescriberUserId
        self.createdTime = createdTime
        self.createdUserId = createdUserId
        self.modifiedTime = modifiedTime
        self.modifiedUserId = modifiedUserId
    }
    
    public enum State: String, Codable, Equatable {
        case draft
        case pending
        case submitted
        case claimed
        case expired
        case active
        case inactive
    }
    
    public struct Revision: Codable, Equatable {
        public var revisionId: Int?
        public var attributes: Attributes?
        
        public init(revisionId: Int? = nil, attributes: Attributes? = nil) {
            self.revisionId = revisionId
            self.attributes = attributes
        }
    }
    
    public struct Attributes: Codable, Equatable {
        public var accountType: AccountType?
        public var caregiverFirstName: String?
        public var caregiverLastName: String?
        public var firstName: String?
        public var lastName: String?
        public var birthday: String?
        public var mrn: String?
        public var email: String?
        public var sex: Sex?
        public var weight: Weight?
        public var yearOfDiagnosis: Int?
        public var phoneNumber: PhoneNumber?
        public var initialSettings: InitialSettings?
        public var training: Training?
        public var therapySettings: TherapySettings?
        public var prescriberTermsAccepted: Bool?
        public var state: State?
        public var createdTime: Date?
        public var createdUserId: String?
        
        public init(accountType: AccountType? = nil,
                    caregiverFirstName: String? = nil,
                    caregiverLastName: String? = nil,
                    firstName: String? = nil,
                    lastName: String? = nil,
                    birthday: String? = nil,
                    mrn: String? = nil,
                    email: String? = nil,
                    sex: Sex? = nil,
                    weight: Weight? = nil,
                    yearOfDiagnosis: Int? = nil,
                    phoneNumber: PhoneNumber? = nil,
                    initialSettings: InitialSettings? = nil,
                    training: Training? = nil,
                    therapySettings: TherapySettings? = nil,
                    prescriberTermsAccepted: Bool? = nil,
                    state: State? = nil,
                    createdTime: Date? = nil,
                    createdUserId: String? = nil) {
            self.accountType = accountType
            self.caregiverFirstName = caregiverFirstName
            self.caregiverLastName = caregiverLastName
            self.firstName = firstName
            self.lastName = lastName
            self.birthday = birthday
            self.mrn = mrn
            self.email = email
            self.sex = sex
            self.weight = weight
            self.yearOfDiagnosis = yearOfDiagnosis
            self.phoneNumber = phoneNumber
            self.initialSettings = initialSettings
            self.training = training
            self.therapySettings = therapySettings
            self.prescriberTermsAccepted = prescriberTermsAccepted
            self.state = state
            self.createdTime = createdTime
            self.createdUserId = createdUserId
        }
        
        public enum State: String, Codable, Equatable {
            case draft
            case pending
            case submitted
        }
    }
    
    public enum AccountType: String, Codable, Equatable {
        case patient
        case caregiver
    }
    
    public enum Sex: String, Codable, Equatable {
        case male
        case female
        case undisclosed
    }
    
    public struct Weight: Codable, Equatable {
        public var value: Double?
        public var units: Units?
        
        public init(value: Double? = nil, units: Units? = nil) {
            self.value = value
            self.units = units
        }
        
        public enum Units: String, Codable, Equatable {
            case kg
        }
    }
    
    public struct PhoneNumber: Codable, Equatable {
        public var countryCode: Int?
        public var number: String?
        
        public init(countryCode: Int? = nil, number: String? = nil) {
            self.countryCode = countryCode
            self.number = number
        }
    }
    
    public struct InitialSettings: Codable, Equatable {
        public var bloodGlucoseUnits: BloodGlucoseUnits?
        public var basalRateSchedule: [BasalRateStart]?
        public var bloodGlucoseTargetPhysicalActivity: BloodGlucoseTarget?
        public var bloodGlucoseTargetPreprandial: BloodGlucoseTarget?
        public var bloodGlucoseTargetSchedule: [BloodGlucoseStartTarget]?
        public var carbohydrateRatioSchedule: [CarbohydrateRatioStart]?
        public var glucoseSafetyLimit: Double?
        public var insulinModel: InsulinModelType?
        public var insulinSensitivitySchedule: [InsulinSensitivityStart]?
        public var basalRateMaximum: BasalRateMaximum?
        public var bolusAmountMaximum: BolusAmountMaximum?
        public var pumpId: String?
        public var cgmId: String?
        
        public init(bloodGlucoseUnits: BloodGlucoseUnits? = nil,
                    basalRateSchedule: [BasalRateStart]? = nil,
                    bloodGlucoseTargetPhysicalActivity: BloodGlucoseTarget? = nil,
                    bloodGlucoseTargetPreprandial: BloodGlucoseTarget? = nil,
                    bloodGlucoseTargetSchedule: [BloodGlucoseStartTarget]? = nil,
                    carbohydrateRatioSchedule: [CarbohydrateRatioStart]? = nil,
                    glucoseSafetyLimit: Double? = nil,
                    insulinModel: InsulinModelType? = nil,
                    insulinSensitivitySchedule: [InsulinSensitivityStart]? = nil,
                    basalRateMaximum: BasalRateMaximum? = nil,
                    bolusAmountMaximum: BolusAmountMaximum? = nil,
                    pumpId: String? = nil,
                    cgmId: String? = nil) {
            self.bloodGlucoseUnits = bloodGlucoseUnits
            self.basalRateSchedule = basalRateSchedule
            self.bloodGlucoseTargetPhysicalActivity = bloodGlucoseTargetPhysicalActivity
            self.bloodGlucoseTargetPreprandial = bloodGlucoseTargetPreprandial
            self.bloodGlucoseTargetSchedule = bloodGlucoseTargetSchedule
            self.carbohydrateRatioSchedule = carbohydrateRatioSchedule
            self.glucoseSafetyLimit = glucoseSafetyLimit
            self.insulinModel = insulinModel
            self.insulinSensitivitySchedule = insulinSensitivitySchedule
            self.basalRateMaximum = basalRateMaximum
            self.bolusAmountMaximum = bolusAmountMaximum
            self.pumpId = pumpId
            self.cgmId = cgmId
        }
    }
    
    public enum Training: String, Codable, Equatable {
        case inPerson
        case inModule
    }
    
    public enum TherapySettings: String, Codable, Equatable {
        case initial
        case transferPumpSettings
    }
    
    public typealias BloodGlucoseUnits = TBloodGlucose.Units
    public typealias BasalRateStart = TPumpSettingsDatum.BasalRateStart
    public typealias BloodGlucoseTarget = TBloodGlucose.Target
    public typealias BloodGlucoseStartTarget = TBloodGlucose.StartTarget
    public typealias CarbohydrateRatioStart = TPumpSettingsDatum.CarbohydrateRatioStart
    public typealias InsulinModelType = TPumpSettingsDatum.InsulinModel.ModelType
    public typealias InsulinSensitivityStart = TPumpSettingsDatum.InsulinSensitivityStart
    public typealias BasalRateMaximum = TPumpSettingsDatum.Basal.RateMaximum
    public typealias BolusAmountMaximum = TPumpSettingsDatum.Bolus.AmountMaximum
}
