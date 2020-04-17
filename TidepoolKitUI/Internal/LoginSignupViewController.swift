//
//  LoginSignupViewController.swift
//  TidepoolKitUI
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import os.log
import UIKit
import TidepoolKit

class LoginSignupViewController: UIViewController, TLoginSignup {
    public weak var delegate: TLoginSignupDelegate?

    public var api: TAPI!

    public var environment: TEnvironment?

    @IBOutlet weak var loginSignupView: UIView!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var keyboardPlaceholderHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.setTitleColor(.lightGray, for: .disabled)
        loginButton.layer.cornerRadius = 4.0

        updateState()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func signupButtonTapped(_ sender: UIButton) {
        alertNotImplemented()
    }

    @IBAction func textFieldEditingChanged(_ sender: UITextField) {
        updateState()
    }

    @IBAction func emailTextFieldDidEndOnExit(_ sender: UITextField) {
        passwordTextField.becomeFirstResponder()
    }

    @IBAction func passwordTextFieldDidEndOnExit(_ sender: UITextField) {
        passwordTextField.resignFirstResponder()
        if loginButton.isEnabled {
            loginButtonTapped(loginButton)
        }
    }

    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        alertNotImplemented()
    }

    @IBAction func loginButtonTapped(_ sender: UIButton) {
        backgroundTapped(self)
        updateState()

        activityIndicatorView.startAnimating()

        api.login(environment: resolvedEnvironment, email: emailTextField.text!, password: passwordTextField.text!) { result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    self.feedbackLabel.text = self.loginFeedback(error: error)
                }
            case .success(let session):
                self.delegate!.loginSignup(self, didCreateSession: session) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            TSharedLogging.error((error as CustomDebugStringConvertible).debugDescription)
                            self.feedbackLabel.text = error.localizedDescription
                        }
                        self.activityIndicatorView.stopAnimating()
                    }
                }
            }
        }
    }

    private func loginFeedback(error: TError) -> String {
        switch error {
        case .requestNotAuthenticated:
            return NSLocalizedString("Wrong username or password.", comment: "The login feedback for the request not authenticated error")
        default:
            return error.localizedDescription
        }
    }

    @IBAction func debugSettingsTapped(_ sender: AnyObject) {
        let actionSheet = UIAlertController(title: NSLocalizedString("Debug", comment: "The title of the debug alert"), message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title:  NSLocalizedString("Environment", comment: "The title of the environment alert action"), style: .default, handler: { action in
            self.selectEnvironment()
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "The title of the Cancel alert action"), style: .cancel))
        present(actionSheet, animated: true)
    }

    private func selectEnvironment() {
        let actionSheet = UIAlertController(title: NSLocalizedString("Environment", comment: "The title of the environment alert"), message: resolvedEnvironment.description, preferredStyle: .actionSheet)
        for environment in api.environments {
            actionSheet.addAction(UIAlertAction(title: environment.description, style: .default, handler: { _ in
                self.environment = environment
            }))
        }
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "The title of the Cancel alert action"), style: .cancel))
        present(actionSheet, animated: true)
    }

    @IBAction func backgroundTapped(_ sender: AnyObject) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardPlaceholderHeightConstraint.constant = keyboardFrame.height
            loginSignupView.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        keyboardPlaceholderHeightConstraint.constant = 0
        loginSignupView.layoutIfNeeded()
    }

    private var resolvedEnvironment: TEnvironment { environment ?? api.environments.first! }

    private func updateState() {
        feedbackLabel.text = nil
        loginButton.isEnabled = emailTextField.text?.isEmpty == false && passwordTextField.text?.isEmpty == false
    }

    // TODO: Temporary, localization not required.
    private func alertNotImplemented() {
        let alert = UIAlertController(title: "Not Implemented", message: "This feature is not yet implemented.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
