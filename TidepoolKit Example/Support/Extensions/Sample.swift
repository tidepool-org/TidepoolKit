//
//  Sample.swift
//  TidepoolKit Example
//
//  Created by Darin Krauss on 3/4/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

struct Sample {
    struct Datum {
        static func data(fullyAdorned: Bool = true) -> [TDatum] {
            var data: [TDatum] = [
                TApplicationSettingsDatum(time: Date(),
                                          name: "Sample Application",
                                          version: "1.2.3"),
                TBloodKetoneDatum(time: Date(),
                                  value: 3.1),
                TCBGDatum(time: Date(),
                          value: 123,
                          units: .milligramsPerDeciliter),
                TCGMSettingsDatum(time: Date(),
                                  manufacturers: ["Acme Pump", "Acme CGM"],
                                  model: "Super Deluxe",
                                  serialNumber: "999666333",
                                  transmitterId: "A1B2C3",
                                  units: .milligramsPerDeciliter,
                                  defaultAlerts: cgmSettingsAlerts,
                                  scheduledAlerts: [TCGMSettingsDatum.ScheduledAlert(name: "Default",
                                                                                     days: ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"],
                                                                                     start: 0,
                                                                                     end: 64800000,
                                                                                     alerts: cgmSettingsAlerts),
                                                    TCGMSettingsDatum.ScheduledAlert(name: "Mondays",
                                                                                     days: ["monday"],
                                                                                     start: 0,
                                                                                     end: 64800000,
                                                                                     alerts: cgmSettingsAlerts)]),
                TFoodDatum(time: Date(),
                           name: "Darn Good Snack",
                           amount: TFoodDatum.Amount(1.0, "cups"),
                           brand: "Acme Foods",
                           code: "1234567890",
                           meal: .other,
                           mealOther: "midnight snack",
                           nutrition: foodNutrition,
                           ingredients: [foodIngredient, foodIngredient]),
                TInsulinDatum(time: Date(),
                              dose: TInsulinDatum.Dose(active: 1.23,
                                                       correction: 2.34,
                                                       food: 3.45,
                                                       total: 4.56),
                              formulation: insulinFormulation,
                              site: "Forehead"),
                TPhysicalActivityDatum(time: Date(),
                                       name: "Exercise",
                                       aggregate: true,
                                       activityType: .other,
                                       activityTypeOther: "extremeSports",
                                       duration: TPhysicalActivityDatum.Duration(1.2, .hours),
                                       distance: TPhysicalActivityDatum.Distance(5.0, .kilometers),
                                       elevationChange: TPhysicalActivityDatum.ElevationChange(500, .meters),
                                       flight: TPhysicalActivityDatum.Flight(count: 160),
                                       lap: TPhysicalActivityDatum.Lap(1, TPhysicalActivityDatum.Distance(5.0, .kilometers)),
                                       step: TPhysicalActivityDatum.Step(count: 12345),
                                       reportedIntensity: .high,
                                       energy: TPhysicalActivityDatum.Energy(800, .kilocalories)),
                TPumpSettingsDatum(time: Date(),
                                   activeScheduleName: "Normal",
                                   basal: TPumpSettingsDatum.Basal(rateMaximum: TPumpSettingsDatum.Basal.RateMaximum(3),
                                                                   temporary: TPumpSettingsDatum.Basal.Temporary(.unitsPerHour)),
                                   basalRateSchedules: ["Default": [TPumpSettingsDatum.BasalRateStart(start: 0, rate: 1.0),
                                                                    TPumpSettingsDatum.BasalRateStart(start: 43200000, rate: 1.5)]],
                                   basalRateSchedulesTimezoneOffset: -480,
                                   bloodGlucoseTargetPreprandial: TBloodGlucose.Target(low: 80, high: 90),
                                   bloodGlucoseTargetSchedules: ["Default": [TBloodGlucose.StartTarget(start: 0, low: 100, high: 110),
                                                                             TBloodGlucose.StartTarget(start: 43200000, low: 110, high: 120)]],
                                   bloodGlucoseTargetSchedulesTimezoneOffset: -420,
                                   bolus: TPumpSettingsDatum.Bolus(amountMaximum: TPumpSettingsDatum.Bolus.AmountMaximum(10),
                                                                   calculator: TPumpSettingsDatum.Bolus.Calculator(enabled: true,
                                                                                                                   insulin: TPumpSettingsDatum.Bolus.Calculator.Insulin(5, .hours)),
                                                                   extended: TPumpSettingsDatum.Bolus.Extended(enabled: true)),
                                   carbohydrateRatioSchedules: ["Default": [TPumpSettingsDatum.CarbohydrateRatioStart(start: 0, amount: 15),
                                                                            TPumpSettingsDatum.CarbohydrateRatioStart(start: 43200000, amount: 20)]],
                                   carbohydrateRatioSchedulesTimezoneOffset: -360,
                                   display: TPumpSettingsDatum.Display(bloodGlucose: TPumpSettingsDatum.Display.BloodGlucose(.milligramsPerDeciliter)),
                                   dosingEnabled: true,
                                   insulinModel: .rapidAdult,
                                   insulinSensitivitySchedules: ["Default": [TPumpSettingsDatum.InsulinSensitivityStart(start: 0, amount: 45),
                                                                             TPumpSettingsDatum.InsulinSensitivityStart(start: 43200000, amount: 60)]],
                                   insulinSensitivitySchedulesTimezoneOffset: -300,
                                   manufacturers: ["Acme Pump"],
                                   model: "Ultra Deluxe",
                                   serialNumber: "a1b2c3d4e5",
                                   suspendThreshold: TPumpSettingsDatum.SuspendThreshold(70, .milligramsPerDeciliter),
                                   units: TPumpSettingsDatum.Units(bloodGlucose: .milligramsPerDeciliter, carbohydrate: .grams)),
                TReportedStateDatum(time: Date(),
                                    states: [TReportedStateDatum.State(.alcohol, severity: 5),
                                             TReportedStateDatum.State(.other, stateOther: "confused")]),
                TSMBGDatum(time: Date(),
                           value: 10.3,
                           units: .millimolesPerLiter,
                           subType: .manual),
                TWaterDatum(time: Date(),
                            amount: TWaterDatum.Amount(1, .liters))
            ]
            
            if fullyAdorned {
                data = adorn(data: data, fullyAdorned: fullyAdorned)
            }
            return data
        }

        fileprivate static var foodIngredient: TFoodDatum.Ingredient {
            return TFoodDatum.Ingredient(name: "Everything",
                                         amount: TFoodDatum.Amount(1.0, "cups"),
                                         brand: "Acme Foods",
                                         code: "1234567890",
                                         nutrition: foodNutrition,
                                         ingredients: [TFoodDatum.Ingredient(name: "ether"),
                                                       TFoodDatum.Ingredient(name: "air")])
        }

        fileprivate static var foodNutrition: TFoodDatum.Nutrition {
            return TFoodDatum.Nutrition(carbohydrate: TFoodDatum.Nutrition.Carbohydrate(net: 30, sugars: 10, dietaryFiber: 5, total: 35),
                                        fat: TFoodDatum.Nutrition.Fat(12),
                                        protein: TFoodDatum.Nutrition.Protein(8),
                                        energy: TFoodDatum.Nutrition.Energy(350, .kilocalories))
        }

        fileprivate static var insulinFormulation: TInsulinDatum.Formulation {
            return TInsulinDatum.Formulation(name: "My Formula",
                                             simple: TInsulinDatum.Formulation.Simple(actingType: .rapid,
                                                                                      brand: "Humalog",
                                                                                      concentration: TInsulinDatum.Formulation.Simple.Concentration(100, .unitsPerML)))
        }
        
        fileprivate static var cgmSettingsAlerts: TCGMSettingsDatum.Alerts {
            let snooze = TCGMSettingsDatum.Alerts.Snooze(30, .minutes)
            return TCGMSettingsDatum.Alerts(enabled: true,
                                            urgentLow: TCGMSettingsDatum.Alerts.LevelAlert(enabled: true, level: 55, units: .milligramsPerDeciliter, snooze: snooze),
                                            urgentLowPredicted: TCGMSettingsDatum.Alerts.LevelAlert(enabled: true, level: 55, units: .milligramsPerDeciliter, snooze: snooze),
                                            low: TCGMSettingsDatum.Alerts.LevelAlert(enabled: true, level: 70, units: .milligramsPerDeciliter, snooze: snooze),
                                            lowPredicted: TCGMSettingsDatum.Alerts.LevelAlert(enabled: true, level: 65, units: .milligramsPerDeciliter, snooze: snooze),
                                            high: TCGMSettingsDatum.Alerts.LevelAlert(enabled: true, level: 180, units: .milligramsPerDeciliter, snooze: snooze),
                                            highPredicted: TCGMSettingsDatum.Alerts.LevelAlert(enabled: true, level: 200, units: .milligramsPerDeciliter, snooze: snooze),
                                            fall: TCGMSettingsDatum.Alerts.RateAlert(enabled: true, rate: 3, units: .milligramsPerDeciliterPerMinute, snooze: snooze),
                                            rise: TCGMSettingsDatum.Alerts.RateAlert(enabled: true, rate: 3, units: .milligramsPerDeciliterPerMinute, snooze: snooze),
                                            noData: TCGMSettingsDatum.Alerts.DurationAlert(enabled: true, duration: 30, units: .minutes, snooze: snooze),
                                            outOfRange: TCGMSettingsDatum.Alerts.DurationAlert(enabled: true, duration: 1, units: .hours, snooze: snooze))
        }
        
        fileprivate static var location: TLocation {
            return TLocation(name: "Home",
                             gps: TLocation.GPS(latitude: TLocation.GPS.Latitude(37.773972),
                                                longitude: TLocation.GPS.Longitude(-122.431297),
                                                elevation: TLocation.GPS.Elevation(50, .meters),
                                                floor: 31,
                                                horizontalAccuracy: TLocation.GPS.Accuracy(10, .meters),
                                                verticalAccuracy: TLocation.GPS.Accuracy(5, .meters),
                                                origin: origin))
        }

        fileprivate static var origin: TOrigin {
            return TOrigin(id: UUID().uuidString,
                           name: "Phone",
                           version: "1.2.3",
                           type: .device,
                           time: Date(),
                           payload: TDictionary(["one": 1]))
        }

        fileprivate static var annotations: [TDictionary] {
            return [TDictionary(["alpha": 1, "beta": ["two"]]),
                    TDictionary(["charlie": ["id": "three"]])]
        }

        fileprivate static var associations: [TAssociation] {
            return [TAssociation(type: .datum, id: "12345678901234567890123456789012", reason: "Any reason will do"),
                    TAssociation(type: .url, url: "https://tidepool.org")]
        }

        fileprivate static var notes: [String] {
            return ["First Note", "Second Note"]
        }

        fileprivate static var payload: TDictionary {
            return TDictionary(["foo": "bar"])
        }

        fileprivate static var tags: [String] {
            return ["First Tag", "Second Tag"]
        }

        fileprivate static func adorn(data: [TDatum], fullyAdorned: Bool = true) -> [TDatum] {
            return data.map { adorn(datum: $0, fullyAdorned: fullyAdorned) }
        }

        fileprivate static func adorn(datum: TDatum, fullyAdorned: Bool = true) -> TDatum {
            if fullyAdorned {
                datum.annotations = annotations
                datum.associations = associations
                datum.clockDriftOffset = 123456
                datum.conversionOffset = 2345
                datum.deviceId = "my-device-id"
                datum.deviceTime = "1999-12-31T12:34:45"
                datum.location = location
                datum.notes = notes
                datum.origin = origin
                datum.payload = payload
                datum.tags = tags
                datum.timezone = "America/Los_Angeles"
                datum.timezoneOffset = -480
            } else {
                datum.origin = TOrigin(id: UUID().uuidString)
            }
            return datum
        }
    }
}
