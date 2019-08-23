//
//  TPKitUISetting.swift
//  TidepoolKitUI
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Supports persistence of String? values using UserDefaults.
public class TPKitUISetting {
    var settingKey: String
    public init(forKey: String) {
        self.settingKey = forKey
        _value = UserDefaults.standard.string(forKey: self.settingKey)
    }
    // writes are persisted...
    var value: String? {
        set(newValue) {
            UserDefaults.standard.set(newValue, forKey: settingKey)
            _value = newValue
        }
        get {
            return _value
        }
    }
    private var _value: String?
}
