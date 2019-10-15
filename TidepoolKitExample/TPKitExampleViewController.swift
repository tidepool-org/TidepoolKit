//
//  TPKitExampleViewController.swift
//  TidepoolKitExample
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
    var session: TPSession?
    
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
            tidepoolKit.refreshSession(session) { [ weak self ]
                result in
                guard let self = self else {
                    return
                }
                switch result {
                case .failure(let error):
                    NSLog("TidepoolKit refreshSession failed with error: \(error), clearing saved session!")
                    self.savedSession.save(nil)
                    self.session = nil
                    self.configureForReachability()
                case .success(let session):
                    NSLog("TidepoolKit refreshed session is: \(session)")
                    self.savedSession.save(session)
                    self.session = session
                    self.configureForReachability()
                }
            }
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(TPKitExampleViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
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
        let loggedIn = self.session != nil
        
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
        if let session = self.session {
            tidepoolKit.logOut(from: session) {
                _ in
                self.session = nil
                self.savedSession.save(nil)
                self.configureForReachability()
            }
        } else {
            self.logIn()
        }
    }
    
    private func logIn() {
        guard loginVC == nil else {
            NSLog("Already presenting UI!")
            return
        }
        var serverHost = defaultServerHost
        NSLog("start with defaultServerHost = \(defaultServerHost)")
        if let host = lastServerHostSetting.value {
            NSLog("found lastServerHostSetting == \(serverHost)")
            serverHost = host
        }
        loginVC = tidepoolKitUI.logInViewController(loginSignupDelegate: self, serverHost: serverHost)
        navigationController?.present(loginVC!, animated: true) {
            () -> Void in
            self.configureForReachability()
            return
        }
    }
    private let defaultServerHost = "qa2.development.tidepool.org"

    
    // MARK: - LoginSignupDelegate

    func loginSignupComplete(_ session: TPSession) {
        guard let loginViewController = loginVC else {
            return
        }
        
        NSLog("loginSignupComplete returned with session: \(session)")
            
        loginViewController.dismiss(animated: true) {
            self.loginVC = nil
            NSLog("TidepoolKit current session is: \(session)")
            self.session = session
            self.savedSession.save(session)
            NSLog("saving lastServerHost as \(session.serverHost)")
            self.lastServerHostSetting.value = session.serverHost
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

