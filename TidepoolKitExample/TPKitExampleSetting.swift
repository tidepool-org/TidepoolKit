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
    let defaults = UserDefaults.standard
    var settingKey: String
    public init(forKey: String) {
        self.settingKey = forKey
    }
    // writes are persisted...
    var value: String? {
        set(newValue) {
            defaults.set(newValue, forKey: settingKey)
            _value = newValue
        }
        get {
            if _value == nil {
                _value = defaults.string(forKey: settingKey)
            }
            return _value
        }
    }
    private var _value: String?
}
