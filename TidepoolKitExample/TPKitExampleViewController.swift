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

class TPKitExampleViewController: UIViewController, LoginSignupDelegate {
    
    let lastServerHostSetting = TPKitExampleSetting(forKey: "testTPKitServerHost")
    let savedSession = TPKitExampleSessionSetting(forKey: "testTPKitSession")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            // Code only executes when tests are running
            NSLog("Testing... exit from TestTableViewController viewDidLoad before completion!")
            return
        }

        tidepoolKit = TidepoolKit.init()
        // Example of setting logger after init time (can also pass into init)
        tidepoolKit.logger = TPKitLoggerExample()
        
        // Example of accessing current TidepoolKit logger...
        if let x = tidepoolKit.logger {
            NSLog("logger type is \(type(of: x))")
        } else {
            NSLog("logger is nil!")
        }

        tidepoolKitUI = TidepoolKitUI.init(tidepoolKit: tidepoolKit, logger: TPKitUILoggerExample()) // pass the instance of TidepoolKit created in the line above!
        
        if let session = savedSession.restore() {
            if case .success = tidepoolKit.logIn(with: session) {
                tidepoolKit.refreshSession { [ weak self ]
                    result in
                    guard let self = self else {
                        return
                    }
                    // if refresh resulted in logged out state, adjust UI
                    guard let session = self.tidepoolKit.currentSession else {
                        NSLog("TidepoolKit refreshSession failed, clearing saved session!")
                        self.savedSession.save(nil)
                        self.configureForReachability()
                        return
                    }
                    NSLog("TidepoolKit refreshed session is: \(session)")
                    self.savedSession.save(session)
                }
            }
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(TPKitExampleViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(TPKitExampleViewController.reachabilityChanged(_:)), name: TidepoolLogInChangedNotification, object: nil)
        configureForReachability()

    }
    private var tidepoolKit: TidepoolKit!
    private var tidepoolKitUI: TidepoolKitUI!

    @objc func reachabilityChanged(_ note: Notification) {
        NSLog("\(#function)")
        DispatchQueue.main.async {
            self.configureForReachability()
        }
    }
    
    func configureForReachability() {
        NSLog("\(#function)")
        let connected = tidepoolKit.isConnectedToNetwork()
        let loggedIn = tidepoolKit.isLoggedIn()
        
        loggedInLabel.text = connected ?
            (loggedIn ? "Logged in to Tidepool" : "Press button to log in!") :
            "No Internet Connection"
        logInButton.isEnabled = connected
        logInButton.setTitle(loggedIn ? "Log out" : "Log in", for: .normal)
    }
    
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var loggedInLabel: UILabel!
    private var loginVC: UIViewController?
    @IBAction func testLoginButtonHandler(_ sender: Any) {
        NSLog("\(#function)")
        if tidepoolKit.isLoggedIn() {
            tidepoolKit.logOut() { _ in }
            savedSession.save(nil)
            self.configureForReachability()
            return
        }
        
        guard loginVC == nil else {
            NSLog("Already presenting UI!")
            return
        }
        var defaultServerHost = tidepoolKit.currentServerHost
        NSLog("start with defaultServerHost = \(defaultServerHost)")
        if let serverHost = lastServerHostSetting.value {
            NSLog("found lastServerHostSetting == \(serverHost)")
            defaultServerHost = serverHost
        }
        loginVC = tidepoolKitUI.logInViewController(loginSignupDelegate: self, defaultServerHost: defaultServerHost)
        navigationController?.present(loginVC!, animated: true) {
            () -> Void in
            self.configureForReachability()
            return
        }
    }
    
    // MARK: - LoginSignupDelegate

    func loginSignupComplete(_ session: TPSession) {
        guard let loginViewController = loginVC else {
            return
        }
        
        NSLog("loginSignupComplete returned with session: \(session)")
            
        loginViewController.dismiss(animated: true) {
            self.loginVC = nil
            if let session = self.tidepoolKit.currentSession {
                NSLog("TidepoolKit current session is: \(session)")
                self.savedSession.save(session)
                NSLog("saving lastServerHost as \(session.serverHost)")
                self.lastServerHostSetting.value = session.serverHost
            }
            self.configureForReachability()
        }
    }

    func loginSignupCancelled() {
        guard let loginViewController = loginVC else {
            return
        }
        
        NSLog("loginSignupComplete returned with cancel!")
            
        loginViewController.dismiss(animated: true) {
            self.loginVC = nil
            self.configureForReachability()
        }
    }


}

