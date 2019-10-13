//
//  TidepoolKitUI.swift
//  TidepoolKitUI
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

public class TidepoolKitUI {
    
    private var tidepoolKit: TidepoolKit
    
    public init(tidepoolKit: TidepoolKit, logger: TPLogging? = nil) {
        globalLogger = logger
        self.tidepoolKit = tidepoolKit
    }
    
    public func logInViewController(loginSignupDelegate: LoginSignupDelegate? = nil, serverHost: String?) -> UIViewController {
        let loginViewController = UIStoryboard(name: "LoginSignup", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController() as! LoginViewController
        loginViewController.loginSignupDelegate = loginSignupDelegate
        loginViewController.tidepoolKit = tidepoolKit
        loginViewController.serverHost = serverHost
        return loginViewController
    }

}

// global logging protocol, optional...
var globalLogger: TPLogging?

