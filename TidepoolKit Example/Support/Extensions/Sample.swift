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
                TFoodDatum(time: Date(),
                           name: "Darn Good Snack",
                           amount: TFoodDatum.Amount(1.0, "cups"),
                           brand: "Acme Foods",
                           code: "1234567890",
                           meal: .other,
                           mealOther: "midnight snack",
                           nutrition: foodNutrition,
                           ingredients: [foodIngredient, foodIngredient]),
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
