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

public struct TPDataNutrition: TPData {
    public static var tpType: TPDataType { return .nutrition }

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
        self.energy = TPDataType.getTypeFromDict(TPDataEnergy.self, rawValue)
        self.carbohydrate = TPDataType.getTypeFromDict(TPDataCarbohydrate.self, rawValue)
        self.fat = TPDataType.getTypeFromDict(TPDataFat.self, rawValue)
        self.protein = TPDataType.getTypeFromDict(TPDataProtein.self, rawValue)
        if energy == nil && carbohydrate == nil && fat == nil && protein == nil {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var resultDict: [String: Any] = [:]
        resultDict["energy"] = energy?.rawValue
        carbohydrate?.addSelfToDict(&resultDict)
        fat?.addSelfToDict(&resultDict)
        protein?.addSelfToDict(&resultDict)
        return resultDict
    }
    
    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
    
}


