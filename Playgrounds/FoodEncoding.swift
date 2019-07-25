//
//  FoodEncoding.swift
//  TidepoolKitTest
//
//  Created by Larry Kenyon on 7/4/19.
//  Copyright © 2019 Tidepool. All rights reserved.
//

import Foundation

import UIKit
import TidepoolKit


public enum TPUserDataType: String {
    case cbg = "cbg"
    case food = "food"
    case basal = "basal"
    case unsupported = "unsupported"
}

public struct Suppressed: Codable {
    public var deliveryType: String?
    public var rate: Float?
    public var type: String?
}

public struct Origin: Encodable  {
    let id: String?
    let name: String?
    let type: String?
    let payload: Dictionary<String, Any>?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        //case payload
    }
    
    public init(id: String?, name: String?, type: String?, payload: Dictionary<String, Any>?) {
        self.id = id
        self.name = name
        self.type = type
        self.payload = payload
    }
    
    var debugDescription: String {
        get {
            var result = "origin: "
            if let id = id {
                result += "\n id: \(id)"
            }
            if let type = type {
                result += "\n type: \(type)"
            }
            if let name = name {
                result += "\n name: \(name)"
            }
            if let payload = payload {
                result += "\n payload: \(payload)"
            }
            return result
        }
    }
}

public struct UserDataCommonOther {
    let origin: Origin?
    let payload: [String: Any]?
    
    public init(origin: Origin?, payload: [String : Any]?) {
        self.origin = origin
        self.payload = payload
    }
}

public class TPUserDataCommon: Encodable {
    
    public let id: String?
    public let time: Date
    
    public init(_ type: TPUserDataType, id: String? = nil , time: Date, common: UserDataCommonOther? = nil) {
        self.type = type
        self.id = id
        self.time = time
        if let common = common {
            self.origin = common.origin
            self.payload = common.payload
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case time
        case origin
        //case payload
    }
    
    // other optional data...
    public var origin: Origin?
    public var payload: [String: Any]?
    
    private func typeStringToType(_ typeStr: String) -> TPUserDataType? {
        switch typeStr {
        case TPUserDataType.cbg.rawValue:
            return .cbg
        case TPUserDataType.basal.rawValue:
            return .basal
        default:
            return nil
        }
    }
    
    var debugDescription: String {
        get {
            var result = "\n id: \(id ?? "nil")"
            result += "\n time: \(time)"
            if let origin = origin {
                result += "\n\(origin.debugDescription)"
            }
            if let payload = payload {
                result += "\npayload: \(payload)"
            }
            return result
        }
    }
    
    //
    // MARK: - Framework private variables, methods
    //
    
    var type: TPUserDataType
    
}

public class TPDataFood: TPUserDataCommon {
    
    public struct Amount: Codable {
        public var value: Float
        public var units: String
    }
    
    public enum Meal: String, Encodable {
        case breakfast = "breakfast"
        case lunch = "lunch"
        case dinner = "dinner"
        case snack = "snack"
        case other = "other"
    }
    
    public enum EnergyUnits: String, Encodable {
        case calories = "calories"
        case kilocalories = "kilocalories" /* (aka dietary Calorie)*/
        case joules = "joules"
        case kilojoules = "kilojoules"
    }
    
    public struct Energy: Encodable {
        public var value: Float         // 0.0 <= x < 10000.0 for kilocalories, converted for other types; 4.1848 joules / calories]
        public var units: EnergyUnits
    }
    
    public struct Fat: Encodable {
        public var value: Float
        public let units = "grams"
    }
    
    public struct Carbohydrate: Encodable {
        public var net: Float             // 0.0 <= x <= 1000.0 (how much was actually accounted for, regardless of total; can also represent assumed carb effect due to protein-only food)
        public let units = "grams"
        public var total: Float?         // 0.0 <= x <= 1000.0 (usually total == dietaryFiber + sugars, but can also include nonDietaryFiber, so  total >= dietaryFiber + sugars)
        public var dietaryFiber: Float? //  0.0 <= x <= 1000.0]
        public var sugars: Float?         //  0.0 <= x <= 1000.0]
        public init(net: Float) {
            self.net = net
        }
    }
    
    public struct Protein: Encodable {
        public var value: Float     // 0.0 <= x <= 1000.0
        public let units = "grams"
    }
    
    public struct Nutrition: Encodable {
        public var energy: Energy? = nil
        public var carbohydrate: Carbohydrate? = nil
        public var fat: Fat? = nil
        public var protein: Protein? = nil
        public init(carbs: Carbohydrate?) {
            self.carbohydrate = carbs
        }
    }
    
    public struct Ingredient: Encodable {
        public var amount: Amount? = nil
        public var brand: String? = nil    // 0 < len <= 100]
        public var code: String? = nil    // 0 < len <= 100; UPC or other]
        public var ingredients: [Ingredient]?
        public var name: String? = nil    // 0 < len <= 100]
        public var nutrition: Nutrition? = nil
    }
    
    public enum AssociationType: String, Encodable {
        case link = "link"
        case datum = "datum"
        case medium = "medium"
        case venue = "venue"
        case food = "food"
    }
    
    public struct Association: Encodable {
        public let type: AssociationType
        public var link: String? = nil        // [url; if and only if type == "link"; 1 <= len <= 2K]
        public var id: String? = nil        // [id; if and only if type == "medium"/"datum"/"venue"/"food"; id to medium/datum/venue/food]
        public var reason: String?             // why is there this association; 1 <= len <= 1000]
    }
    
    public struct Latitude: Encodable {
        public let value: Float     // -90.0 <= x <= 90.0
        public let units = "degrees"
        public init(value: Float) {
            self.value = value
        }
        // TODO: add validator!
    }
    
    public struct Longitude: Encodable {
        public let value: Float     // -180.0 <= x <= 180.0
        public let units = "degrees"
        public init(value: Float) {
            self.value = value
        }
    }
    
    public struct Elevation: Encodable {
        public enum Units: String, Encodable {
            case feet = "feet"
            case meters = "meters"
        }
        public let value: Float     // -10000.0 <= x <= 10000.0 meters (and equivalent feet)
        public let units: Units
        public init(value: Float, units: Units) {
            self.value = value
            self.units = units
        }
    }
    
    public struct HorizontalAccuracy: Encodable {
        public enum Units: String, Encodable {
            case feet = "feet"
            case meters = "meters"
        }
        public let value: Float     // 0.0 <= x <= 1000.0 meters (and equivalent feet)]
        public let units: Units
        public init(value: Float, units: Units) {
            self.value = value
            self.units = units
        }
    }
    
    public struct VerticalAccuracy: Encodable {
        public enum Units: String, Encodable {
            case feet = "feet"
            case meters = "meters"
        }
        public let value: Float     // 0.0 <= x <= 1000.0 meters (and equivalent feet)]
        public let units: Units
        public init(value: Float, units: Units) {
            self.value = value
            self.units = units
        }
    }
    
    public struct GPS: Encodable {
        public var latitude: Latitude? = nil
        public var longitude: Longitude? = nil
        public var elevation: Elevation? = nil
        public var floor: Int? = nil        // -1000 <= x <= 1000]
        public var horizontalAccuracy: HorizontalAccuracy? = nil
        public var verticalAccuracy: VerticalAccuracy? = nil
        public var origin: Origin? = nil    // since associated GPS data can be generated by a device other than the base data type]
    }
    
    public struct Location: Encodable {
        // one or more of name and gps are required
        public var name: String? = nil        // 1 <= len < 100]
        public var gps: GPS? = nil
        
    }
    
    public var name: String? = nil         // 0 < len <= 100]
    public var brand: String? = nil     //  0 < len <= 100]
    public var code: String? = nil     //  0 < len <= 100; UPC or other]
    public var meal: Meal? = nil
    public var mealOther: String? = nil     // specified if and only if meal == "other"; 0 < len <= 100]
    public var amount: Amount? = nil
    public var nutrition: Nutrition? = nil
    public var ingredients: [Ingredient]? = nil
    
    public var location: Location? = nil
    public var tags: [String]? = nil     // set of tag (string; 1 <= len <= 100); 1 <= len <= 100; duplicates not allowed; returns ordered alphabetically
    public var notes: [String]? = nil     // array of note (string; 1 <= len <= 1000; NOT the same as messages); optional; 1 <= len <= 100; retains order
    public var associations: [Association]? = nil    // 1 <= len <= 100
    
    // Other: Origin (part of common), but not Payload?
    
    public init?(_ id: String?, time: Date, carbs: Float, common: UserDataCommonOther? = nil) {
        self.nutrition = Nutrition(carbs: Carbohydrate(net: carbs))
        super.init(.food, id: id, time: time, common: common)
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
    
}

if let foodSample = TPDataFood(nil, time: Date(), carbs: 30, common: nil) {
    print("created TPDataFood: \(foodSample.debugDescription)")
    foodSample.name = "Oatmeal"
    
    let encoder = JSONEncoder()
    do {
        let resultData = try encoder.encode(foodSample)
        print("encoded as: \(NSString(data: resultData, encoding: String.Encoding.utf8.rawValue)! as String)")
        let result = try JSONSerialization.jsonObject(with: resultData) as? [String: Any]
        print("local result = \(result)")
    } catch {
        print("APIUserDataFood: unable to serialize self!")
    }
    
    
} else {
    print("\(#function) failed to create food sample!")
}




