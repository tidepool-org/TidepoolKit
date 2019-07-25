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

/// Supports persistence of a handful of String? values used by APIConnect. The default TPKitSettingUserDefaults uses UserDefaults, but a different subclass could be provided by the TidepoolKit framework user: given a key (String), returns an object with a .value String var that is write-thru persistent.
public class TPKitSetting {
    var settingKey: String
    public required init(forKey: String) {
        self.settingKey = forKey
    }
    // writes are persisted...
    public var value: String?
}

class TPKitSettingUserDefaults: TPKitSetting {
    let defaults = UserDefaults.standard
    required init(forKey: String) {
        super.init(forKey: forKey)
        _value = defaults.string(forKey: self.settingKey)
    }
    
    override var value: String? {
        set(newValue) {
            defaults.set(newValue, forKey: self.settingKey)
            _value = newValue
        }
        get {
            return _value
        }
    }
    private var _value: String?
}
