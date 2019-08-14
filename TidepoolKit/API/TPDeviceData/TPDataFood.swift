
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

public class TPDataFood: TPDeviceData, TPData {
    
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
    public let name: String? 		// 0 < len <= 100]
	public let brand: String?       //  0 < len <= 100]
	public let code: String?        //  0 < len <= 100; UPC or other]
	public let meal: Meal?
	public let mealOther: String?   // specified if and only if meal == "other"; 0 < len <= 100]
	public let amount: TPDataAmount?
	public let nutrition: TPDataNutrition?
	public let ingredients: [TPDataIngredient]?

	public init?(time: Date, name: String? = nil, carbs: Double) {
        self.name = name
        self.brand = nil
        self.code = nil
        self.meal = nil
        self.mealOther = nil
        self.amount = nil
        self.nutrition = TPDataNutrition(carbs: TPDataCarbohydrate(net: carbs))
        self.ingredients = nil
        super.init(time: time)
	}

    //
    public init?(time: Date, name: String? = nil, brand: String? = nil, code: String? = nil, meal: Meal? = nil, mealOther: String? = nil, amount: TPDataAmount? = nil, nutrition: TPDataNutrition? = nil, ingredients: [TPDataIngredient]? = nil) {
        self.name = name
        self.brand = brand
        self.code = code
        self.meal = meal
        self.mealOther = mealOther
        self.amount = amount
        self.nutrition = nutrition
        self.ingredients = ingredients
        super.init(time: time)
        // validate...
        if !TPDataType.validateString(self.name, maxLen: 100) { return nil }
        if !TPDataType.validateString(self.brand, maxLen: 100) { return nil }
        if !TPDataType.validateString(self.code, maxLen: 100) { return nil }
        if !TPDataType.validateString(self.mealOther, maxLen: 100) { return nil }
        if mealOther != nil && self.meal != .other { return nil }
        if amount != nil && self.amount == nil { return nil }
        if nutrition != nil && self.nutrition == nil { return nil }
        if ingredients != nil && self.ingredients == nil { return nil }
        // return nil if all fields are nil...
        if self.name == nil, self.brand == nil, self.code == nil, self.meal == nil, self.amount == nil, self.nutrition == nil, self.ingredients == nil {
            return nil
        }
   }

    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    required override public init?(rawValue: RawValue) {
        self.name = rawValue["name"] as? String
        self.brand = rawValue["brand"] as? String
        self.code = rawValue["code"] as? String
        if let mealStr = rawValue["meal"] as? String {
            self.meal = Meal(rawValue: mealStr)
        } else {
            self.meal = nil
        }
        self.mealOther = rawValue["mealOther"] as? String
        self.amount = TPDataType.getTypeFromDict(TPDataAmount.self, rawValue)
        self.nutrition = TPDataType.getTypeFromDict(TPDataNutrition.self, rawValue)
        var ingredients: [TPDataIngredient] = []
        if let ingredientsArray: [Any] = rawValue["ingredients"] as? [Any] {
             for item in ingredientsArray {
                if let rawIngredient = item as? [String: Any] {
                    if let ingredient = TPDataIngredient(rawValue: rawIngredient) {
                        ingredients.append(ingredient)
                    }
                }
            }
        }
        if !ingredients.isEmpty {
            self.ingredients = ingredients
        } else {
            self.ingredients = nil
        }
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
