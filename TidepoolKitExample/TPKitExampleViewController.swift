//
//  TPKitExampleViewController.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import UIKit
import TidepoolKit
import TidepoolKitUI

class TPKitExampleViewController: UIViewController {

    let currentServiceSetting = TPKitExampleSetting(forKey: "testService")

    override func viewDidLoad() {
        super.viewDidLoad()
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            // Code only executes when tests are running
            NSLog("Testing... exit from TestTableViewController viewDidLoad before completion!")
            return
        }

        self.tpKit = TidepoolKit.init()
        // Example of setting logger after init time (can also pass into init)
        tpKit.logger = TPKitLoggerExample()
        
        // Example of accessing current TidepoolKit logger...
        if let x = tpKit.logger {
            print("logger type is \(type(of: x))")
        } else {
            print("logger is nil!")
        }

        self.tpKitUI = TidepoolKitUI.init(tpKit: tpKit, logger: TPKitUILoggerExample()) // pass the instance of TidepoolKit created in the line above!
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(TPKitExampleViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TPKitExampleViewController.reachabilityChanged(_:)), name: TidepoolLogInChangedNotification, object: nil)
        configureForReachability()

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
            tpKit.logOut() { _ in }
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

