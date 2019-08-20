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

public struct TPDataIngredient: TPData {
    public static var tpType: TPDataType { return .ingredient }
    
	public let amount: TPDataAmount?
	public let brand: String?	// len <= 100
	public let code: String?	// len <= 100; UPC or other
	public let ingredients: [TPDataIngredient]? // count <= 100
	public let name: String?	// len <= 100
	public let nutrition: TPDataNutrition?
    
    public init?(amount: TPDataAmount? = nil, brand: String? = nil, code: String? = nil, ingredients: [TPDataIngredient]? = nil, name: String? = nil, nutrition: TPDataNutrition? = nil) {
        self.amount = amount
        self.nutrition = nutrition
        self.code = code
        self.brand = brand
        self.name = name
        if let ingredients = ingredients, ingredients.count < 100, !ingredients.isEmpty {
            self.ingredients = ingredients
        } else {
            self.ingredients = nil
        }
        // validate
        guard TPDataType.validateString(code, maxLen: 100) else { return nil }
        guard TPDataType.validateString(brand, maxLen: 100) else { return nil }
        guard TPDataType.validateString(name, maxLen: 100) else { return nil }
        if ingredients != nil && self.ingredients == nil {
            LogError("Err: Ingredients array invalid!")
            return nil
        }
        if amount == nil && brand == nil && code == nil && ingredients == nil && name == nil && nutrition == nil {
            LogError("Err: Ingredient contains no data!")
            return nil
        }
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        if let amountDict = rawValue["amount"] as? [String: Any] {
            self.amount = TPDataAmount(rawValue: amountDict)
        } else {
            self.amount = nil
        }
        if let nutritionDict = rawValue["nutrition"] as? [String: Any] {
            self.nutrition = TPDataNutrition(rawValue: nutritionDict)
        } else {
            self.nutrition = nil
        }
        var ingredientsArray: [TPDataIngredient] = []
        if let ingredientRawArray = rawValue["ingredients"] as? [Any] {
            for item in ingredientRawArray {
                if let itemDict = item as? [String: Any] {
                    if let ingredient = TPDataIngredient(rawValue: itemDict) {
                        ingredientsArray.append(ingredient)
                    }
                }
            }
        }
        self.ingredients = ingredientsArray.isEmpty ? nil : ingredientsArray
        self.brand = rawValue["brand"] as? String
        self.code = rawValue["code"] as? String
        self.name = rawValue["name"] as? String
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        if let amount = amount {
            resultDict["amount"] = amount.rawValue
        }
        if let brand = brand {
            resultDict["brand"] = brand as Any
        }
        if let code = code {
            resultDict["code"] = code as Any
        }
        if let name = name {
            resultDict["name"] = name as Any
        }
        nutrition?.addSelfToDict(&resultDict)
        if let ingredients = ingredients {
            var rawIngredients: [RawValue] = []
            for item in ingredients {
                rawIngredients.append(item.rawValue)
            }
            if !rawIngredients.isEmpty {
                resultDict["ingredients"] = rawIngredients
            }
        }
        return resultDict
    }
    
}

