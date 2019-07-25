
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
import HealthKit

public class TPDataFood: TPData {

	public struct Amount {
	    public var value: Float
	    public var units: String
	}

	public enum Meal: String {
		case breakfast = "breakfast"
        case lunch = "lunch"
        case dinner = "dinner"
        case snack = "snack"
        case other = "other"
	}

	public enum EnergyUnits: String {
		case calories = "calories"
        case kilocalories = "kilocalories" /* (aka dietary Calorie)*/
        case joules = "joules"
        case kilojoules = "kilojoules"
	}

	public struct Energy {
	    public var value: Float 		// 0.0 <= x < 10000.0 for kilocalories, converted for other types; 4.1848 joules / calories]
	    public var units: EnergyUnits
	}

	public struct Fat {
	    public var value: Float
	    public let units = "grams"
	}

	public struct Carbohydrate {
	    public var net: Float 			// 0.0 <= x <= 1000.0 (how much was actually accounted for, regardless of total; can also represent assumed carb effect due to protein-only food)
	    public let units = "grams"
		public var total: Float? 		// 0.0 <= x <= 1000.0 (usually total == dietaryFiber + sugars, but can also include nonDietaryFiber, so  total >= dietaryFiber + sugars)
		public var dietaryFiber: Float? //  0.0 <= x <= 1000.0]
		public var sugars: Float? 		//  0.0 <= x <= 1000.0]
		public init(net: Float) {
			self.net = net
		}
	}

	public struct Protein {
	    public var value: Float 	// 0.0 <= x <= 1000.0
	    public let units = "grams"
	}

	public struct Nutrition {
		public var energy: Energy? = nil
		public var carbohydrate: Carbohydrate? = nil
		public var fat: Fat? = nil
		public var protein: Protein? = nil
		public init(carbs: Carbohydrate?) {
			self.carbohydrate = carbs
		}
	}

	public struct Ingredient {
		public var amount: Amount? = nil
		public var brand: String? = nil	// 0 < len <= 100]
		public var code: String? = nil	// 0 < len <= 100; UPC or other]
		public var ingredients: [Ingredient]?
		public var name: String? = nil	// 0 < len <= 100]
		public var nutrition: Nutrition? = nil
	}

	public enum AssociationType: String {
		case link = "link"
        case datum = "datum"
        case medium = "medium"
        case venue = "venue"
        case food = "food"
	}

	public struct Association {
		public let type: AssociationType
		public var link: String? = nil		// [url; if and only if type == "link"; 1 <= len <= 2K]
		public var id: String? = nil		// [id; if and only if type == "medium"/"datum"/"venue"/"food"; id to medium/datum/venue/food]
		public var reason: String? 			// why is there this association; 1 <= len <= 1000]
	}

	public struct Latitude {
		public let value: Float 	// -90.0 <= x <= 90.0
		public let units = "degrees"
		public init(value: Float) {
			self.value = value
		}
		// TODO: add validator!
	}

	public struct Longitude {
		public let value: Float 	// -180.0 <= x <= 180.0
		public let units = "degrees"
		public init(value: Float) {
			self.value = value
		}
	}

    // TODO: move to common...
	public struct Elevation {
		public enum Units: String {
			case feet = "feet"
            case meters = "meters"
		}
		public let value: Float 	// -10000.0 <= x <= 10000.0 meters (and equivalent feet)
		public let units: Units
		public init(value: Float, units: Units) {
			self.value = value
			self.units = units
		}
	}

    // TODO: move to common...
	public struct HorizontalAccuracy {
        public enum Units: String {
            case feet = "feet"
            case meters = "meters"
        }
		public let value: Float 	// 0.0 <= x <= 1000.0 meters (and equivalent feet)]
		public let units: Units
		public init(value: Float, units: Units) {
			self.value = value
			self.units = units
		}
	}

    // TODO: move to common...
	public struct VerticalAccuracy {
        public enum Units: String {
            case feet = "feet"
            case meters = "meters"
        }
		public let value: Float 	// 0.0 <= x <= 1000.0 meters (and equivalent feet)]
		public let units: Units
		public init(value: Float, units: Units) {
			self.value = value
			self.units = units
		}
	}

    // TODO: move to common...
	public struct GPS {
		public var latitude: Latitude? = nil
		public var longitude: Longitude? = nil
		public var elevation: Elevation? = nil
		public var floor: Int? = nil		// -1000 <= x <= 1000]
		public var horizontalAccuracy: HorizontalAccuracy? = nil
		public var verticalAccuracy: VerticalAccuracy? = nil
		public var origin: TPUserDataOrigin? = nil	// since associated GPS data can be generated by a device other than the base data type]
	}

    // TODO: move to common...
	public struct Location {
		// one or more of name and gps are required
		public var name: String? = nil		// 1 <= len < 100]
		public var gps: GPS? = nil

	} 

    //
    // type specific data
    //
    public var name: String? = nil 		// 0 < len <= 100]
	public var brand: String? = nil 	//  0 < len <= 100]
	public var code: String? = nil 	//  0 < len <= 100; UPC or other]
	public var meal: Meal? = nil
	public var mealOther: String? = nil 	// specified if and only if meal == "other"; 0 < len <= 100]
	public var amount: Amount? = nil
	public var nutrition: Nutrition? = nil
	public var ingredients: [Ingredient]? = nil

    // TODO: move to common...
	public var location: Location? = nil
	public var tags: [String]? = nil 	// set of tag (string; 1 <= len <= 100); 1 <= len <= 100; duplicates not allowed; returns ordered alphabetically
	public var notes: [String]? = nil 	// array of note (string; 1 <= len <= 1000; NOT the same as messages); optional; 1 <= len <= 100; retains order
	public var associations: [Association]? = nil	// 1 <= len <= 100

	public init?(_ id: String?, time: Date, carbs: Float) {
        self.nutrition = Nutrition(carbs: Carbohydrate(net: carbs))
        super.init(id: id, time: time)
        type = .food
	}

    public override var debugDescription: String {
        get {
            var result = "\nuser data type: \(type.rawValue)"
            if let carbs = self.nutrition?.carbohydrate {
                result += "\n carbs: \(carbs.net) \(carbs.units)"
            }
            result += super.debugDescription
            return result
        }
    }
    
    //
    // MARK: - RawRepresentable
    //
    
    required public init?(rawValue: RawValue) {
        if let nutrition = rawValue["nutrition"] as? [String: Any] {
            if let carb = nutrition["carbohydrate"] as? [String: Any] {
                let net = carb["net"] as? NSNumber
                if let net = net {
                    self.nutrition = Nutrition(carbs: Carbohydrate(net: net.floatValue))
                }
            }
        }

        super.init(rawValue: rawValue)
        type = .food
    }
    
    public override var rawValue: RawValue {
        var result = super.rawValue
        // add in type-specific data...
        // TODO: finish!
        result["name"] = name as Any?
        result["brand"] = brand as Any?
        result["code"] = code as Any?
        if let nutrition = nutrition {
            var nutritionDict = [String: AnyObject]()
            if let carbohydrate = nutrition.carbohydrate {
                var carbsDict = [
                    "net": carbohydrate.net,
                    "units": carbohydrate.units
                    ] as [String : Any]
                carbsDict["total"] = carbohydrate.total
                carbsDict["dietaryFiber"] = carbohydrate.dietaryFiber
                carbsDict["sugars"] = carbohydrate.sugars
                nutritionDict["carbohydrate"] = carbsDict as AnyObject?
            }
            result["nutrition"] = nutritionDict as AnyObject?
        }
        return result
    }
    
}
