//
//  UserDefaults.swift
//  TidepoolKit Example
//
//  Created by Darin Krauss on 2/21/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

extension UserDefaults {
    private enum Key: String {
        case environment = "org.tidepool.TidepoolKit-Example.environment"
        case session = "org.tidepool.TidepoolKit-Example.session"
    }

    var environment: TEnvironment? {
        get {
            guard let environmentRawValue = dictionary(forKey: Key.environment.rawValue) else {
                return nil
            }
            return TEnvironment(rawValue: environmentRawValue)
        }
        set {
            set(newValue?.rawValue, forKey: Key.environment.rawValue)
        }
    }

    // NOTE: The recommended mechanism to persist a Tidepool session is via the OS keychain. However,
    // for example purposes ONLY, use UserDefaults.
    var session: TSession? {
        get {
            guard let sessionRawValue = dictionary(forKey: Key.session.rawValue) else {
                return nil
            }
            return TSession(rawValue: sessionRawValue)
        }
        set {
            set(newValue?.rawValue, forKey: Key.session.rawValue)
        }
    }
}
