//
//  TPDataNutrition.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataNutrition: TPData {
    public static var tpType: TPDataType { return .nutrition }

	public let energy: TPDataEnergy?
	public let carbohydrate: TPDataCarbohydrate?
	public let fat: TPDataFat?
	public let protein: TPDataProtein?
    
    public init(energy: TPDataEnergy? = nil, carbohydrate: TPDataCarbohydrate? = nil, fat: TPDataFat? = nil, protein: TPDataProtein? = nil) {
        self.energy = energy
		self.carbohydrate = carbohydrate
        self.fat = fat
        self.protein = protein
	}
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        self.energy = TPDataEnergy.getSelfFromDict(rawValue)
        self.carbohydrate = TPDataCarbohydrate.getSelfFromDict(rawValue)
        self.fat = TPDataFat.getSelfFromDict(rawValue)
        self.protein = TPDataProtein.getSelfFromDict(rawValue)
        if energy == nil && carbohydrate == nil && fat == nil && protein == nil {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        energy?.addSelfToDict(&rawValue)
        carbohydrate?.addSelfToDict(&rawValue)
        fat?.addSelfToDict(&rawValue)
        protein?.addSelfToDict(&rawValue)
        return rawValue
    }
    
}

