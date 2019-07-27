
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

	public enum Meal: String {
		case breakfast = "breakfast"
        case lunch = "lunch"
        case dinner = "dinner"
        case snack = "snack"
        case other = "other"
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
	public var nutrition: TPDataNutrition? = nil
	public var ingredients: [Ingredient]? = nil

    // TODO: move to common...
	public var location: Location? = nil
	public var tags: [String]? = nil 	// set of tag (string; 1 <= len <= 100); 1 <= len <= 100; duplicates not allowed; returns ordered alphabetically
	public var notes: [String]? = nil 	// array of note (string; 1 <= len <= 1000; NOT the same as messages); optional; 1 <= len <= 100; retains order
	public var associations: [Association]? = nil	// 1 <= len <= 100

	public init?(time: Date, carbs: Double) {
        self.nutrition = TPDataNutrition(carbs: TPDataCarbohydrate(net: carbs))
        super.init(time: time)
        type = .food
	}

    public init?(time: Date, nutrition: TPDataNutrition) {
        self.nutrition = nutrition
        super.init(time: time)
        type = .food
    }

    public override var debugDescription: String {
        get {
            var result = "\nuser data type: \(type.rawValue)"
            if let nutrition = self.nutrition {
                result += "\n\(nutrition.debugDescription)"
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
                self.nutrition = TPDataNutrition(carbs: TPDataCarbohydrate(rawValue: carb))
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
        result["nutrition"] = nutrition?.rawValue
//        if let nutrition = nutrition {
//            var nutritionDict = [String: AnyObject]()
//            if let carbs = nutrition.carbohydrate {
//                let carbsDict = carbs.rawValue
//                nutritionDict["carbohydrate"] = carbsDict as AnyObject?
//            }
//            result["nutrition"] = nutritionDict as AnyObject?
//        }
        return result
    }
    
}
