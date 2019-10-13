//
//  LoginViewController.swift
//  TidepoolKitUI
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import UIKit
import TidepoolKit

public protocol LoginSignupDelegate: AnyObject {

    func loginSignupComplete(_ session: TPSession)
    func loginSignupCancelled()
}

class LoginViewController: UIViewController {

    var loginSignupDelegate: LoginSignupDelegate?
    var tidepoolKit: TidepoolKit!
    var serverHost: String?
    
    @IBOutlet weak var inputContainerView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var errorFeedbackLabel: UILabel!
    @IBOutlet weak var serviceButton: UIButton!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    @IBOutlet weak var networkOfflineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureForReachability()
        updateButtonStates()
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.textFieldDidChange), name: UITextField.textDidChangeNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(LoginViewController.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: nil)
        
        configureCurrentServerButton()
    }
    
    static var firstTime = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LoginViewController.firstTime {
            LoginViewController.firstTime = false
            if tidepoolKit.isLoggedIn() {
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
        let connected = tidepoolKit.isConnectedToNetwork()
        networkOfflineLabel.text = connected ? "Connected to Internet" : "No Internet Connection"
    }

    // MARK: - Login
     
    @IBAction func tapOutsideFieldHandler(_ sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    @IBAction func passwordEnterHandler(_ sender: AnyObject) {
        passwordTextField.resignFirstResponder()
        if (loginButton.isEnabled) {
            loginButtonTapped(self)
        }
    }
    
    @IBAction func emailEnterHandler(_ sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        tapOutsideFieldHandler(self)
        if let loginSignupDelegate = loginSignupDelegate {
            loginSignupDelegate.loginSignupCancelled()
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: AnyObject) {
        updateButtonStates()
        tapOutsideFieldHandler(self)
        loginIndicator.startAnimating()
        
        //LogInfo("Logging into \(server?.rawValue ?? "default") server!")
        tidepoolKit.logIn(with: emailTextField.text!, password: passwordTextField.text!, serverHost: serverHost) {
            result in
            LogInfo("Login result: \(result)")
            self.processLoginResult(result)
        }
    }
    
    private func processLoginResult(_ result: Result<TPSession, TPError>) {
        loginIndicator.stopAnimating()
        switch result {
        case .success(let session):
            //LogInfo("Login success: \(user)")
            logInComplete(session)
        case .failure(let error):
            var errorText = "Check your Internet connection!"
            switch error {
            case .unauthorized:
                errorText = "Wrong email or password!"
            default:
                break
            }
            errorFeedbackLabel.text = errorText
            errorFeedbackLabel.isHidden = false
        }
    }
    
    private func logInComplete(_ session: TPSession) {
        if let loginSignupDelegate = loginSignupDelegate {
            loginSignupDelegate.loginSignupComplete(session)
        } else {
            dismiss(animated: true)
        }
    }

    @objc func textFieldDidChange() {
        updateButtonStates()
    }
    
    private func updateButtonStates() {
        errorFeedbackLabel.isHidden = true
        let connected = tidepoolKit.isConnectedToNetwork()
        // login button
        if (emailTextField.text != "" && passwordTextField.text != "" && connected) {
            loginButton.isEnabled = true
            if #available(iOSApplicationExtension 13.0, *) {
                loginButton.setTitleColor(UIColor.label, for:UIControl.State())
            } else {
                // Fallback on earlier versions
                loginButton.setTitleColor(UIColor.black, for:UIControl.State())
            }
        } else {
            loginButton.isEnabled = false
            loginButton.setTitleColor(UIColor.gray, for:UIControl.State())
        }
    }
    
    private var currentServerHost: String {
        return serverHost ?? tidepoolKit.currentServerHost
    }
    
    private func configureCurrentServerButton() {
        serviceButton.setTitle(currentServerHost, for: .normal)
    }
    
    var dnsFetcher = DNSSrvRecordFetcher()

    @IBAction func selectServiceButtonHandler(_ sender: Any) {

        // TODO: show activity indicator while lookup is in progress!
        let lookupStarted = dnsFetcher.doDNSSrvRecordLookup() {
            urlArray in
            NSLog("DNS lookup completed with result: \(urlArray)")
            self.presentServiceChoicePopup(urlArray)
        }
        
        if lookupStarted {
            NSLog("DNS lookup started!")
        } else {
             NSLog("DNS lookup failed to start!")
            // only choice will be the default host!
            presentServiceChoicePopup([])
        }
    }
    
    private func presentServiceChoicePopup(_ dynamicHosts: [String]) {
        let defaultHost = tidepoolKit.currentServerHost // default when not logged in
        var hostArray: [String] = dynamicHosts
        // always include the default host...
        if !hostArray.contains(defaultHost) {
            hostArray.insert(defaultHost, at: 0)
        }
        let actionSheet = UIAlertController(title: "Server" + " (" + currentServerHost + ")", message: "", preferredStyle: .alert)
        for Host in hostArray {
            actionSheet.addAction(UIAlertAction(title: Host, style: .default, handler: { Void in
                self.serverHost = Host
                self.configureCurrentServerButton()
            }))
        }
        present(actionSheet, animated: true, completion: nil)

    }

}
