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
    
    /**
     Instantiate a view controller for logging into Tidepool. The client should present this view controller, and respond to callbacks on the passed in delegate protocol.
     
     - parameter loginSignupDelegate: LoginSignupDelegate for callbacks.
     - parameter serverHost: Default service host to use. The login UI supports a debug UI for changing this. The actual service host used will be passed back as part of the TPSession object upon successful login.
     - returns: initialized login view controller.
     */
    public func logInViewController(loginSignupDelegate: LoginSignupDelegate, serverHost: String) -> UIViewController {
        let loginViewController = UIStoryboard(name: "LoginSignup", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController() as! LoginViewController
        loginViewController.loginSignupDelegate = loginSignupDelegate
        loginViewController.tidepoolKit = tidepoolKit
        loginViewController.serverHost = serverHost
        return loginViewController
    }

}

// global logging protocol, optional...
var globalLogger: TPLogging?

