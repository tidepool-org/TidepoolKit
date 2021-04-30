//
//  TPrescriptionTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 4/30/21.
//  Copyright © 2021 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPrescriptionTests: XCTestCase {
    static let prescription = TPrescription(
        id: "1234567890",
        patientUserId: "a1b2c3d4e5",
        accessCode: "ABCDEF",
        state: .claimed,
        latestRevision: TPrescriptionRevisionTests.revision,
        expirationTime: Date.test,
        prescriberUserId: "b2c3d4e5f6",
        createdTime: Date.test,
        createdUserId: "c3d4e5f6g7",
        modifiedTime: Date.test,
        modifiedUserId: "d4e5f6g7h8")
    static let prescriptionJSONDictionary: [String: Any] = [
        "id": "1234567890",
        "patientUserId": "a1b2c3d4e5",
        "accessCode": "ABCDEF",
        "state": TPrescription.State.claimed.rawValue,
        "latestRevision": TPrescriptionRevisionTests.revisionJSONDictionary,
        "expirationTime": Date.testJSONString,
        "prescriberUserId": "b2c3d4e5f6",
        "createdTime": Date.testJSONString,
        "createdUserId": "c3d4e5f6g7",
        "modifiedTime": Date.testJSONString,
        "modifiedUserId": "d4e5f6g7h8"
    ]
    
    func testInitializer() {
        let prescription = TPrescriptionTests.prescription
        XCTAssertEqual(prescription.id, "1234567890")
        XCTAssertEqual(prescription.patientUserId, "a1b2c3d4e5")
        XCTAssertEqual(prescription.accessCode, "ABCDEF")
        XCTAssertEqual(prescription.state, .claimed)
        XCTAssertEqual(prescription.latestRevision, TPrescriptionRevisionTests.revision)
        XCTAssertEqual(prescription.expirationTime, Date.test)
        XCTAssertEqual(prescription.prescriberUserId, "b2c3d4e5f6")
        XCTAssertEqual(prescription.createdTime, Date.test)
        XCTAssertEqual(prescription.createdUserId, "c3d4e5f6g7")
        XCTAssertEqual(prescription.modifiedTime, Date.test)
        XCTAssertEqual(prescription.modifiedUserId, "d4e5f6g7h8")
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TPrescriptionTests.prescription, TPrescriptionTests.prescriptionJSONDictionary)
    }
}

class TPrescriptionStateTests: XCTestCase {
    func testState() {
        XCTAssertEqual(TPrescription.State.draft.rawValue, "draft")
        XCTAssertEqual(TPrescription.State.pending.rawValue, "pending")
        XCTAssertEqual(TPrescription.State.submitted.rawValue, "submitted")
        XCTAssertEqual(TPrescription.State.claimed.rawValue, "claimed")
        XCTAssertEqual(TPrescription.State.expired.rawValue, "expired")
        XCTAssertEqual(TPrescription.State.active.rawValue, "active")
        XCTAssertEqual(TPrescription.State.inactive.rawValue, "inactive")
    }
}

class TPrescriptionRevisionTests: XCTestCase {
    static let revision = TPrescription.Revision(revisionId: 123, attributes: TPrescriptionAttributesTests.attributes)
    static let revisionJSONDictionary: [String: Any] = [
        "revisionId": 123,
        "attributes": TPrescriptionAttributesTests.attributesJSONDictionary
    ]
    
    func testInitializer() {
        let revision = TPrescriptionRevisionTests.revision
        XCTAssertEqual(revision.revisionId, 123)
        XCTAssertEqual(revision.attributes, TPrescriptionAttributesTests.attributes)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TPrescriptionRevisionTests.revision, TPrescriptionRevisionTests.revisionJSONDictionary)
    }
}

class TPrescriptionAttributesTests: XCTestCase {
    static let attributes = TPrescription.Attributes(
        accountType: .caregiver,
        caregiverFirstName: "Parent",
        caregiverLastName: "Doe",
        firstName: "Child",
        lastName: "Doe",
        birthday: "2004-01-04",
        mrn: "1234567890",
        email: "parent.doe@email.com",
        sex: .undisclosed,
        weight: TPrescriptionWeightTests.weight,
        yearOfDiagnosis: 2020,
        phoneNumber: TPrescriptionPhoneNumberTests.phoneNumber,
        initialSettings: TPrescriptionInitialSettingsTests.initialSettings,
        training: .inModule,
        therapySettings: .initial,
        prescriberTermsAccepted: true,
        state: .submitted,
        createdTime: Date.test,
        createdUserId: "abcdefghijklmnopqrstuvwxyz")
    static let attributesJSONDictionary: [String: Any] = [
        "accountType": TPrescription.AccountType.caregiver.rawValue,
        "caregiverFirstName": "Parent",
        "caregiverLastName": "Doe",
        "firstName": "Child",
        "lastName": "Doe",
        "birthday": "2004-01-04",
        "mrn": "1234567890",
        "email": "parent.doe@email.com",
        "sex": TPrescription.Sex.undisclosed.rawValue,
        "weight": TPrescriptionWeightTests.weightJSONDictionary,
        "yearOfDiagnosis": 2020,
        "phoneNumber": TPrescriptionPhoneNumberTests.phoneNumberJSONDictionary,
        "initialSettings": TPrescriptionInitialSettingsTests.initialSettingsJSONDictionary,
        "training": TPrescription.Training.inModule.rawValue,
        "therapySettings": TPrescription.TherapySettings.initial.rawValue,
        "prescriberTermsAccepted": true,
        "state": TPrescription.Attributes.State.submitted.rawValue,
        "createdTime": Date.testJSONString,
        "createdUserId": "abcdefghijklmnopqrstuvwxyz"
    ]
    
    func testInitializer() {
        let attributes = TPrescriptionAttributesTests.attributes
        XCTAssertEqual(attributes.accountType, .caregiver)
        XCTAssertEqual(attributes.caregiverFirstName, "Parent")
        XCTAssertEqual(attributes.caregiverLastName, "Doe")
        XCTAssertEqual(attributes.firstName, "Child")
        XCTAssertEqual(attributes.lastName, "Doe")
        XCTAssertEqual(attributes.birthday, "2004-01-04")
        XCTAssertEqual(attributes.mrn, "1234567890")
        XCTAssertEqual(attributes.email, "parent.doe@email.com")
        XCTAssertEqual(attributes.sex, .undisclosed)
        XCTAssertEqual(attributes.weight, TPrescriptionWeightTests.weight)
        XCTAssertEqual(attributes.yearOfDiagnosis, 2020)
        XCTAssertEqual(attributes.phoneNumber, TPrescriptionPhoneNumberTests.phoneNumber)
        XCTAssertEqual(attributes.initialSettings, TPrescriptionInitialSettingsTests.initialSettings)
        XCTAssertEqual(attributes.training, .inModule)
        XCTAssertEqual(attributes.therapySettings, .initial)
        XCTAssertEqual(attributes.prescriberTermsAccepted, true)
        XCTAssertEqual(attributes.state, .submitted)
        XCTAssertEqual(attributes.createdTime, Date.test)
        XCTAssertEqual(attributes.createdUserId, "abcdefghijklmnopqrstuvwxyz")
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TPrescriptionAttributesTests.attributes, TPrescriptionAttributesTests.attributesJSONDictionary)
    }
}

class TPrescriptionAttributesStateTests: XCTestCase {
    func testState() {
        XCTAssertEqual(TPrescription.Attributes.State.draft.rawValue, "draft")
        XCTAssertEqual(TPrescription.Attributes.State.pending.rawValue, "pending")
        XCTAssertEqual(TPrescription.Attributes.State.submitted.rawValue, "submitted")
    }
}

class TPrescriptionAccountTypeTests: XCTestCase {
    func testAccountType() {
        XCTAssertEqual(TPrescription.AccountType.patient.rawValue, "patient")
        XCTAssertEqual(TPrescription.AccountType.caregiver.rawValue, "caregiver")
    }
}

class TPrescriptionSexTests: XCTestCase {
    func testSex() {
        XCTAssertEqual(TPrescription.Sex.male.rawValue, "male")
        XCTAssertEqual(TPrescription.Sex.female.rawValue, "female")
        XCTAssertEqual(TPrescription.Sex.undisclosed.rawValue, "undisclosed")
    }
}

class TPrescriptionWeightTests: XCTestCase {
    static let weight = TPrescription.Weight(value: 123, units: .kg)
    static let weightJSONDictionary: [String: Any] = [
        "value": 123,
        "units": "kg"
    ]
    
    func testInitializer() {
        let weight = TPrescriptionWeightTests.weight
        XCTAssertEqual(weight.value, 123)
        XCTAssertEqual(weight.units, .kg)
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TPrescriptionWeightTests.weight, TPrescriptionWeightTests.weightJSONDictionary)
    }
}

class TPrescriptionWeightUnitsTests: XCTestCase {
    func testUnits() {
        XCTAssertEqual(TPrescription.Weight.Units.kg.rawValue, "kg")
    }
}

class TPrescriptionPhoneNumberTests: XCTestCase {
    static let phoneNumber = TPrescription.PhoneNumber(countryCode: 123, number: "(234) 345-4566")
    static let phoneNumberJSONDictionary: [String: Any] = [
        "countryCode": 123,
        "number": "(234) 345-4566"
    ]
    
    func testInitializer() {
        let phoneNumber = TPrescriptionPhoneNumberTests.phoneNumber
        XCTAssertEqual(phoneNumber.countryCode, 123)
        XCTAssertEqual(phoneNumber.number, "(234) 345-4566")
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TPrescriptionPhoneNumberTests.phoneNumber, TPrescriptionPhoneNumberTests.phoneNumberJSONDictionary)
    }
}

class TPrescriptionInitialSettingsTests: XCTestCase {
    static let initialSettings = TPrescription.InitialSettings(
        bloodGlucoseUnits: .milligramsPerDeciliter,
        basalRateSchedule: [TPumpSettingsDatumBasalRateStartTests.basalRateStart,
                            TPumpSettingsDatumBasalRateStartTests.basalRateStart],
        bloodGlucoseTargetPhysicalActivity: TBloodGlucoseTargetTests.target,
        bloodGlucoseTargetPreprandial: TBloodGlucoseTargetTests.target,
        bloodGlucoseTargetSchedule: [TBloodGlucoseStartTargetTests.startTarget,
                                     TBloodGlucoseStartTargetTests.startTarget],
        carbohydrateRatioSchedule: [TPumpSettingsDatumCarbohydrateRatioStartTests.carbohydrateRatioStart,
                                    TPumpSettingsDatumCarbohydrateRatioStartTests.carbohydrateRatioStart],
        glucoseSafetyLimit: 78.9,
        insulinModel: .rapidChild,
        insulinSensitivitySchedule: [TPumpSettingsDatumInsulinSensitivityStartTests.insulinSensitivityStart,
                                     TPumpSettingsDatumInsulinSensitivityStartTests.insulinSensitivityStart],
        basalRateMaximum: TPumpSettingsDatumBasalRateMaximumTests.rateMaximum,
        bolusAmountMaximum: TPumpSettingsDatumBolusAmountMaximumTests.amountMaximum,
        pumpId: "ABCDEFGHIJ",
        cgmId: "1234567890")
    static let initialSettingsJSONDictionary: [String: Any] = [
        "bloodGlucoseUnits": TBloodGlucose.Units.milligramsPerDeciliter.rawValue,
        "basalRateSchedule": [TPumpSettingsDatumBasalRateStartTests.basalRateStartJSONDictionary,
                              TPumpSettingsDatumBasalRateStartTests.basalRateStartJSONDictionary],
        "bloodGlucoseTargetPhysicalActivity": TBloodGlucoseTargetTests.targetJSONDictionary,
        "bloodGlucoseTargetPreprandial": TBloodGlucoseTargetTests.targetJSONDictionary,
        "bloodGlucoseTargetSchedule": [TBloodGlucoseStartTargetTests.startTargetJSONDictionary,
                                       TBloodGlucoseStartTargetTests.startTargetJSONDictionary],
        "carbohydrateRatioSchedule": [TPumpSettingsDatumCarbohydrateRatioStartTests.carbohydrateRatioStartJSONDictionary,
                                      TPumpSettingsDatumCarbohydrateRatioStartTests.carbohydrateRatioStartJSONDictionary],
        "glucoseSafetyLimit": 78.9,
        "insulinModel": TPumpSettingsDatum.InsulinModel.ModelType.rapidChild.rawValue,
        "insulinSensitivitySchedule": [TPumpSettingsDatumInsulinSensitivityStartTests.insulinSensitivityStartJSONDictionary,
                                       TPumpSettingsDatumInsulinSensitivityStartTests.insulinSensitivityStartJSONDictionary],
        "basalRateMaximum": TPumpSettingsDatumBasalRateMaximumTests.rateMaximumJSONDictionary,
        "bolusAmountMaximum": TPumpSettingsDatumBolusAmountMaximumTests.amountMaximumJSONDictionary,
        "pumpId": "ABCDEFGHIJ",
        "cgmId": "1234567890"
    ]
    
    func testInitializer() {
        let initialSettings = TPrescriptionInitialSettingsTests.initialSettings
        XCTAssertEqual(initialSettings.bloodGlucoseUnits, .milligramsPerDeciliter)
        XCTAssertEqual(initialSettings.basalRateSchedule, [TPumpSettingsDatumBasalRateStartTests.basalRateStart,
                                                           TPumpSettingsDatumBasalRateStartTests.basalRateStart])
        XCTAssertEqual(initialSettings.bloodGlucoseTargetPhysicalActivity, TBloodGlucoseTargetTests.target)
        XCTAssertEqual(initialSettings.bloodGlucoseTargetPreprandial, TBloodGlucoseTargetTests.target)
        XCTAssertEqual(initialSettings.bloodGlucoseTargetSchedule, [TBloodGlucoseStartTargetTests.startTarget,
                                                                    TBloodGlucoseStartTargetTests.startTarget])
        XCTAssertEqual(initialSettings.carbohydrateRatioSchedule, [TPumpSettingsDatumCarbohydrateRatioStartTests.carbohydrateRatioStart,
                                                                   TPumpSettingsDatumCarbohydrateRatioStartTests.carbohydrateRatioStart])
        XCTAssertEqual(initialSettings.glucoseSafetyLimit, 78.9)
        XCTAssertEqual(initialSettings.insulinModel, .rapidChild)
        XCTAssertEqual(initialSettings.insulinSensitivitySchedule, [TPumpSettingsDatumInsulinSensitivityStartTests.insulinSensitivityStart,
                                                                    TPumpSettingsDatumInsulinSensitivityStartTests.insulinSensitivityStart])
        XCTAssertEqual(initialSettings.basalRateMaximum, TPumpSettingsDatumBasalRateMaximumTests.rateMaximum)
        XCTAssertEqual(initialSettings.bolusAmountMaximum, TPumpSettingsDatumBolusAmountMaximumTests.amountMaximum)
        XCTAssertEqual(initialSettings.pumpId, "ABCDEFGHIJ")
        XCTAssertEqual(initialSettings.cgmId, "1234567890")
    }
    
    func testCodableAsJSON() {
        XCTAssertCodableAsJSON(TPrescriptionInitialSettingsTests.initialSettings, TPrescriptionInitialSettingsTests.initialSettingsJSONDictionary)
    }
}

class TPrescriptionTrainingTests: XCTestCase {
    func testTraining() {
        XCTAssertEqual(TPrescription.Training.inPerson.rawValue, "inPerson")
        XCTAssertEqual(TPrescription.Training.inModule.rawValue, "inModule")
    }
}

class TPrescriptionTherapySettingsTests: XCTestCase {
    func testTherapySettings() {
        XCTAssertEqual(TPrescription.TherapySettings.initial.rawValue, "initial")
        XCTAssertEqual(TPrescription.TherapySettings.transferPumpSettings.rawValue, "transferPumpSettings")
    }
}
