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

import UIKit
import TidepoolKit
import TidepoolKitUI

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tpKit = TidepoolKit.sharedInstance
        tpKitUI = TidepoolKitUI.sharedInstance
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(TestViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TestViewController.reachabilityChanged(_:)), name: TidepoolLogInChangedNotification, object: nil)
        configureForReachability()

        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            // Code only executes when tests are running
            NSLog("Testing... exit from TestTableViewController viewDidLoad before completion!")
            return
        }
        
        if tpKit.isLoggedIn() && tpKit.isConnectedToNetwork() {
            tpKit.updateLoginUserWithServiceProfileInfo() {
                result in
            }
            tpKit.updateLoginUserWithServiceSettingsInfo() {
                result in
            }
            tpKit.getAccessUsers() {
                result in
            }
        }
    }
    private var tpKit: TidepoolKit!
    private var tpKitUI: TidepoolKitUI!

    @objc func reachabilityChanged(_ note: Notification) {
        NSLog("\(#function)")
        DispatchQueue.main.async {
            self.configureForReachability()
        }
    }
    
    func configureForReachability() {
        NSLog("\(#function)")
        let connected = tpKit.isConnectedToNetwork()
        let loggedIn = tpKit.isLoggedIn()
        
        loggedInLabel.text = connected ?
            (loggedIn ? "Logged in to Tidepool" : "Press button to log in!") :
            "No Internet Connection"
        logInButton.isEnabled = connected
        logInButton.setTitle(loggedIn ? "Log out" : "Log in", for: .normal)
    }
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var loggedInLabel: UILabel!
    private var presentingLoginUI = false
    @IBAction func testLoginButtonHandler(_ sender: Any) {
        NSLog("\(#function)")
        if tpKit.isLoggedIn() {
            tpKit.logOut()
            self.configureForReachability()
            return
        }
        
        guard !presentingLoginUI else {
            NSLog("Already presenting UI!")
            return
        }
        let loginVC = tpKitUI.logInViewController()
        presentingLoginUI = true
        self.navigationController?.present(loginVC, animated: true) {
            () -> Void in
            self.presentingLoginUI = false
            return
        }
    }
    

}

