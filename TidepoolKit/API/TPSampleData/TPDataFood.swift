
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

public class TPDataFood: TPSampleData, TPData {
    
    //
    // MARK: - TPData protocol
    //
    public static var tpType: TPDataType { return .food }
    
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
	public var amount: TPDataAmount? = nil
	public let nutrition: TPDataNutrition?
	public var ingredients: [TPDataIngredient]? = nil

    // TODO: move to common...
	public var location: Location? = nil
	public var tags: [String]? = nil 	// set of tag (string; 1 <= len <= 100); 1 <= len <= 100; duplicates not allowed; returns ordered alphabetically
	public var notes: [String]? = nil 	// array of note (string; 1 <= len <= 1000; NOT the same as messages); optional; 1 <= len <= 100; retains order
	public var associations: [Association]? = nil	// 1 <= len <= 100

	public init?(time: Date, carbs: Double) {
        self.nutrition = TPDataNutrition(carbs: TPDataCarbohydrate(net: carbs))
        // TPSampleData fields
        super.init(time: time)
	}

    public init?(time: Date, nutrition: TPDataNutrition) {
        self.nutrition = nutrition
        // TPSampleData fields
        super.init(time: time)
   }

    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    required override public init?(rawValue: RawValue) {
        self.nutrition = TPDataType.getTypeFromDict(TPDataNutrition.self, rawValue)
        if let rawIngredients: [RawValue] = rawValue["ingredients"] as? [RawValue] {
            var ingredients: [TPDataIngredient] = []
            for item in rawIngredients {
                if let ingredient = TPDataType.getTypeFromDict(TPDataIngredient.self, item) {
                    ingredients.append(ingredient)
                }
            }
            if !ingredients.isEmpty {
                self.ingredients = ingredients
            }
        }
        // TODO: finish!
        
        // base properties in superclass...
        super.init(rawValue: rawValue)
    }
    
    override public var rawValue: RawValue {
        // start with common data
        var result = self.baseRawValue(type(of: self).tpType)
        // add in type-specific data...
        // TODO: finish!
        result["name"] = name as Any?
        result["brand"] = brand as Any?
        result["code"] = code as Any?
        result["nutrition"] = nutrition?.rawValue
        if let ingredients = ingredients {
            var rawIngredients: [RawValue] = []
            for item in ingredients {
                rawIngredients.append(item.rawValue)
            }
            if !rawIngredients.isEmpty {
                result["ingredients"] = rawIngredients
            }
        }
        return result
    }
    
}
