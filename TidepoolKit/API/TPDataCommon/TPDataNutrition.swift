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

public struct TPDataNutrition: RawRepresentable  {
	public let energy: TPDataEnergy?
	public let carbohydrate: TPDataCarbohydrate?
	public let fat: TPDataFat?
	public let protein: TPDataProtein?
    
    public init?(energy: TPDataEnergy? = nil, carbs: TPDataCarbohydrate? = nil, fat: TPDataFat? = nil, protein: TPDataProtein? = nil) {
        self.energy = energy
		self.carbohydrate = carbs
        self.fat = fat
        self.protein = protein
        if energy == nil && carbs == nil && fat == nil && protein == nil {
            return nil
        }
	}
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        let energyDict = rawValue["energy"] as? RawValue
        self.energy = energyDict != nil ? TPDataEnergy(rawValue: energyDict!) : nil
        let carbDict = rawValue["carbohydrate"] as? RawValue
        self.carbohydrate = carbDict != nil ? TPDataCarbohydrate(rawValue: carbDict!) : nil
        let fatDict = rawValue["fat"] as? RawValue
        self.fat = fatDict != nil ? TPDataFat(rawValue: fatDict!) : nil
        let proteinDict = rawValue["protein"] as? RawValue
        self.protein = proteinDict != nil ? TPDataProtein(rawValue: proteinDict!) : nil
        if energy == nil && carbohydrate == nil && fat == nil && protein == nil {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["energy"] = energy?.rawValue
        resultDict["carbohydrate"] = carbohydrate?.rawValue
        resultDict["fat"] = fat?.rawValue
        resultDict["protein"] = protein?.rawValue
        return resultDict
    }
    
    var debugDescription: String {
        get {
            var result = "nutrition: "
            if let energy = energy {
                result += "\n\(energy.debugDescription)"
            }
            if let carbohydrate = carbohydrate {
                result += "\n\(carbohydrate.debugDescription)"
            }
            if let fat = fat {
                result += "\n\(fat.debugDescription)"
            }
            if let protein = protein {
                result += "\n\(protein.debugDescription)"
            }
            return result
        }
    }
    
}


