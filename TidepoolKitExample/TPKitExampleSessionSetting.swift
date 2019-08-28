//
//  TPKitExampleSessionSetting.swift
//  TidepoolKitExample
//
//  Created by Larry Kenyon on 8/28/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

import TidepoolKit

/// Supports persistence of TPSession and TPDataset objects using UserDefaults.
public class TPKitExampleSessionSetting {
    let settingKey: String
    let defaults = UserDefaults.standard
    public init(forKey: String) {
        self.settingKey = forKey
    }
    
    func save(_ session: TPSession?) {
        guard let session = session else {
            NSLog("Clearing saved session from defaults and token store!")
            defaults.set(nil, forKey: self.settingKey)
            saveAuthToken(nil)
            return
        }
        var sessionRaw = session.rawValue
        guard JSONSerialization.isValidJSONObject(sessionRaw) else {
            NSLog("Unable to convert session rawValue to json: \(sessionRaw)!")
            return
        }
        // save auth token separately!
        guard let authToken = sessionRaw["authenticationToken"] as? String else {
            NSLog("Session rawValue missing auth token string: \(sessionRaw)!")
            return
        }
        sessionRaw["authenticationToken"] = nil
         // save remaining session object in user defaults
        guard let sessionJsonData = try? JSONSerialization.data(withJSONObject: sessionRaw) else {
            NSLog("Unable to serialize rawValue \(sessionRaw)!")
            return
        }
        defaults.set(sessionJsonData, forKey: self.settingKey)
        saveAuthToken(authToken)
        NSLog("Saved session!")
    }
    
    func restore() -> TPSession? {
        guard let sessionJsonData = defaults.object(forKey: settingKey) as? Data else {
            NSLog("No session found in defaults!")
            return nil
        }
        guard let json: Any = try? JSONSerialization.jsonObject(with: sessionJsonData) else {
            NSLog("Persisted session data not json decodable!")
            return nil
        }
        guard var sessionRaw = json as? [String: Any] else {
            NSLog("Persisted session json not a [String: Any]: \(json)!")
            return nil
        }
        guard let token = restoreAuthToken() else {
            NSLog("No persisted token found!")
            return nil
        }
        sessionRaw["authenticationToken"] = token
        guard let session = TPSession(rawValue: sessionRaw) else {
            NSLog("Unable to create TPSession from persisted data!")
            return nil
        }
        NSLog("Restored session!")
        return session
    }
    
    /// override saveAuthKey and restoreAuthKey to save authorization key in a more secure manner (e.g., in Key Store).
    /// Pass nil to clear!
    func saveAuthToken(_ token: String?) {
        // for now, save in user defaults...
        let authSettingKey = settingKey + "_auth"
        defaults.set(token, forKey: authSettingKey)
        if let token = token {
            NSLog("Saved token \(token) with key \(authSettingKey)")
        } else {
            NSLog("Cleared token with key \(authSettingKey)")
        }
    }
    
    func restoreAuthToken() -> String? {
        let authSettingKey = settingKey + "_auth"
        let token = defaults.string(forKey: authSettingKey)
        if let token = token {
            NSLog("Restored token \(token) using key \(authSettingKey)!")
        } else {
            NSLog("No token with key \(authSettingKey) found!")
        }
        return token
    }
    
}
