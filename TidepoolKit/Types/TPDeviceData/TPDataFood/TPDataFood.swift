
//
//  TPDataFood.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import HealthKit

public class TPDataFood: TPDeviceData, TPData {
    
    // TPData protocol
    public static var tpType: TPDataType { return .food }
    
	public enum Meal: String {
		case breakfast = "breakfast"
        case lunch = "lunch"
        case dinner = "dinner"
        case snack = "snack"
        case other = "other"
	}

    public let name: String? 		// 0 < len <= 100]
	public let brand: String?       //  0 < len <= 100]
	public let code: String?        //  0 < len <= 100; UPC or other]
	public let meal: Meal?
	public let mealOther: String?   // specified if and only if meal == "other"; 0 < len <= 100]
	public let amount: TPDataAmount?
	public let nutrition: TPDataNutrition?
	public let ingredients: [TPDataIngredient]?

	public init(time: Date, name: String? = nil, carbohydrate: Double) {
        self.name = name
        self.brand = nil
        self.code = nil
        self.meal = nil
        self.mealOther = nil
        self.amount = nil
        self.nutrition = TPDataNutrition(carbohydrate: TPDataCarbohydrate(net: carbohydrate))
        self.ingredients = nil
        super.init(.food, time: time)
	}

    public init(time: Date, name: String? = nil, brand: String? = nil, code: String? = nil, meal: Meal? = nil, mealOther: String? = nil, amount: TPDataAmount? = nil, nutrition: TPDataNutrition? = nil, ingredients: [TPDataIngredient]? = nil) {
        self.name = name
        self.brand = brand
        self.code = code
        self.meal = meal
        self.mealOther = mealOther
        self.amount = amount
        self.nutrition = nutrition
        self.ingredients = ingredients
        super.init(.food, time: time)
    }

    // MARK: - RawRepresentable

    public typealias RawValue = [String: Any]

    required public init?(rawValue: RawValue) {
        self.name = rawValue["name"] as? String
        self.brand = rawValue["brand"] as? String
        self.code = rawValue["code"] as? String
        if let mealStr = rawValue["meal"] as? String {
            self.meal = Meal(rawValue: mealStr)
        } else {
            self.meal = nil
        }
        self.mealOther = rawValue["mealOther"] as? String
        self.amount = TPDataAmount.getSelfFromDict(rawValue)
        self.nutrition = TPDataNutrition.getSelfFromDict(rawValue)
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
        var dict = super.rawValue
        // add in type-specific data...
        // TODO: finish!
        dict["name"] = name
        dict["brand"] = brand
        dict["code"] = code
        dict["nutrition"] = nutrition?.rawValue
        if let ingredients = ingredients {
            var rawIngredients: [RawValue] = []
            for item in ingredients {
                rawIngredients.append(item.rawValue)
            }
            if !rawIngredients.isEmpty {
                dict["ingredients"] = rawIngredients
            }
        }
        return dict
    }
    
}
