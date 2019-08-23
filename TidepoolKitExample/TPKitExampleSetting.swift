//
//  TPKitExampleSetting.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/20/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Supports persistence of TPSession and TPDataset objects using UserDefaults.
public class TPKitExampleSetting {
    var settingKey: String
    public init(forKey: String) {
        self.settingKey = forKey
    }
    // writes are persisted...
    var value: String? {
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: self.settingKey)
            _value = newValue
        }
        get {
            return _value
        }
    }
    private var _value: String?
}
