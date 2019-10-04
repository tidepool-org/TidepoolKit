//
//  TidepoolKitUI.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit


public class TidepoolKitUI {
    
    private var tpKit: TidepoolKit
    
    public init(tpKit: TidepoolKit, logger: TPKitLogging? = nil) {
        clientLogger = logger
        self.tpKit = tpKit
    }
    
    public func logInViewController(loginSignupDelegate: LoginSignupDelegate? = nil, defaultServerHost: String?) -> UIViewController {
        let loginViewController = UIStoryboard(name: "LoginSignup", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController() as! LoginViewController
        loginViewController.loginSignupDelegate = loginSignupDelegate
        loginViewController.tpKit = self.tpKit
        loginViewController.serverHost = defaultServerHost
        return loginViewController
    }

}

// global logging protocol, optional...
var clientLogger: TPKitLogging?

