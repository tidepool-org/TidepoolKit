//
//  TPDataIngredient.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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
        guard validateString(code, maxLen: 100) else { return nil }
        guard validateString(brand, maxLen: 100) else { return nil }
        guard validateString(name, maxLen: 100) else { return nil }
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
        amount?.addSelfToDict(&resultDict)
        resultDict["brand"] = brand
        resultDict["code"] = code
        resultDict["name"] = name
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

