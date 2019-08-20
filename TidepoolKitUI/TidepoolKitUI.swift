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
import TidepoolKit


public class TidepoolKitUI {
    
    private var tpKit: TidepoolKit
    
    public init(tpKit: TidepoolKit, logger: TPKitLogging? = nil) {
        clientLogger = logger
        self.tpKit = tpKit
    }
    
    public func logInViewController(loginSignupDelegate: LoginSignupDelegate? = nil) -> UIViewController {
        let loginViewController = UIStoryboard(name: "LoginSignup", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController() as! LoginViewController
        loginViewController.loginSignupDelegate = loginSignupDelegate
        loginViewController.tpKit = self.tpKit
        return loginViewController
    }

}

// global logging protocol, optional...
var clientLogger: TPKitLogging?

