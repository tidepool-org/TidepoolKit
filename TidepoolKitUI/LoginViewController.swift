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

class LoginViewController: UIViewController {

    @IBOutlet weak var inputContainerView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorFeedbackLabel: UILabel!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var networkOfflineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tpKit = TidepoolKit.sharedInstance
        configureForReachability()
        updateButtonStates()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.textFieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        self.serviceButton.setTitle(tpKit.currentService, for: .normal)
    }
    private var tpKit: TidepoolKit!
    
    static var firstTime = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LoginViewController.firstTime {
            LoginViewController.firstTime = false
            if tpKit.isLoggedIn() {
                NSLog("Already logged in!")
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
    // MARK: - Segues
    //
    
    @IBAction func logout(_ segue: UIStoryboardSegue) {
        NSLog("unwind segue to login view controller!")
        if tpKit.isLoggedIn() {
            tpKit.logOut()
        }
        self.parent?.dismiss(animated: true)
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
        
        tpKit.logIn(emailTextField.text!, password: passwordTextField.text!) {
            result in
            NSLog("Login result: \(result)")
            self.processLoginResult(result)
        }
    }
    
    private func processLoginResult(_ result: Result<TPUser, TidepoolKitError>) {
        self.loginIndicator.stopAnimating()
        switch result {
        case .success(let user):
            NSLog("Login success: \(user)")
            self.logInComplete()
        case .failure(let error):
            NSLog("login failed! Error: \(error)")
            var errorText = "Check your Internet connection!"
            if error == .unauthorized {
                errorText = "Wrong email or password!"
            }
            self.errorFeedbackLabel.text = errorText
            self.errorFeedbackLabel.isHidden = false
        }
    }
    
    private func logInComplete() {
        self.dismiss(animated: true)
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
    
    @IBAction func selectServiceButtonHandler(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Server" + " (" + tpKit.currentService + ")", message: "", preferredStyle: .actionSheet)
        for serverName in tpKit.kSortedServerNames {
            actionSheet.addAction(UIAlertAction(title: serverName, style: .default, handler: { Void in
                self.tpKit.switchToServer(serverName)
                self.serviceButton.setTitle(self.tpKit.currentService, for: .normal)
            }))
        }
        self.present(actionSheet, animated: true, completion: nil)
    }

}
