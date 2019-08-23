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


public protocol LoginSignupDelegate: AnyObject {

    func loginSignupComplete(_ session: TPSession)

}


class LoginViewController: UIViewController {

    var loginSignupDelegate: LoginSignupDelegate?
    var tpKit: TidepoolKit!

    @IBOutlet weak var inputContainerView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorFeedbackLabel: UILabel!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var networkOfflineLabel: UILabel!
    
    private var currentServerName = TPKitUISetting(forKey: "tpKitUIcurrentServer")
    private var currentServer: TidepoolServer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForReachability()
        updateButtonStates()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.textFieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        
        self.configureCurrentServer()
    }
    
    static var firstTime = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LoginViewController.firstTime {
            LoginViewController.firstTime = false
            if tpKit.isLoggedIn() {
                //LogError("Already logged in!")
            }
        }
    }
    
    @objc func reachabilityChanged(_ note: Notification) {
        DispatchQueue.main.async {
            self.configureForReachability()
        }
    }
    
    func configureForReachability() {
        let connected = tpKit.isConnectedToNetwork()
        networkOfflineLabel.text = connected ? "Connected to Internet" : "No Internet Connection"
    }
    
    //
    // MARK: - Login
    //
    
    @IBAction func tapOutsideFieldHandler(_ sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func passwordEnterHandler(_ sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        if (loginButton.isEnabled) {
            login_button_tapped(self)
        }
    }
    
    @IBAction func emailEnterHandler(_ sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func login_button_tapped(_ sender: AnyObject) {
        updateButtonStates()
        tapOutsideFieldHandler(self)
        loginIndicator.startAnimating()
        
        //LogInfo("Logging into \(server?.rawValue ?? "default") server!")
        tpKit.logIn(emailTextField.text!, password: passwordTextField.text!, server: self.currentServer) {
            result in
            LogInfo("Login result: \(result)")
            self.processLoginResult(result)
        }
    }
    
    private func processLoginResult(_ result: Result<TPSession, TidepoolKitError>) {
        self.loginIndicator.stopAnimating()
        switch result {
        case .success(let session):
            //LogInfo("Login success: \(user)")
            self.logInComplete(session)
        case .failure(let error):
            var errorText = "Check your Internet connection!"
            switch error {
            case .unauthorized:
                errorText = "Wrong email or password!"
            default:
                break
            }
            self.errorFeedbackLabel.text = errorText
            self.errorFeedbackLabel.isHidden = false
        }
    }
    
    private func logInComplete(_ session: TPSession) {
        if let loginSignupDelegate = loginSignupDelegate {
            loginSignupDelegate.loginSignupComplete(session)
        } else {
            self.dismiss(animated: true)
        }
    }

    @objc func textFieldDidChange() {
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        errorFeedbackLabel.isHidden = true
        let connected = tpKit.isConnectedToNetwork()
        // login button
        if (emailTextField.text != "" && passwordTextField.text != "" && connected) {
            loginButton.isEnabled = true
            loginButton.setTitleColor(UIColor.black, for:UIControl.State())
        } else {
            loginButton.isEnabled = false
            loginButton.setTitleColor(UIColor.lightGray, for:UIControl.State())
        }
    }
    
    private func configureCurrentServer(_ server: TidepoolServer? = nil) {
        if let server = server {
            self.currentServerName.value = server.rawValue
        } else if currentServerName.value == nil {
            currentServerName.value = TidepoolServer.allCases[0].rawValue
        }
        let serverName = currentServerName.value!
        self.currentServer = TidepoolServer(rawValue: serverName)!
        self.serviceButton.setTitle(serverName, for: .normal)
    }
    
    @IBAction func selectServiceButtonHandler(_ sender: Any) {
        guard let curServerName = currentServerName.value else {
            return
        }
        let actionSheet = UIAlertController(title: "Server" + " (" + curServerName + ")", message: "", preferredStyle: .alert)
        for server in TidepoolServer.allCases {
            actionSheet.addAction(UIAlertAction(title: server.rawValue, style: .default, handler: { Void in
                self.configureCurrentServer(server)
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }

}
