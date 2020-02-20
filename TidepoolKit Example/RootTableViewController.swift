//
//  RootTableViewController.swift
//  TidepoolKit Example
//
//  Created by Darin Krauss on 1/10/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import os.log
import UIKit
import TidepoolKit
import TidepoolKitUI

class RootTableViewController: UITableViewController {
    private let api = TAPI()
    private var environment: TEnvironment?
    private var session: TSession? {
        didSet {
            tableView.reloadData()
        }
    }

    private enum Section: Int, CaseIterable {
        case status
        case authentication
    }

    private enum Authentication: Int, CaseIterable {
        case login
        case refresh
        case logout
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section)! {
        case .status:
            return NSLocalizedString("Status", comment: "The title for the header of the status section")
        case .authentication:
            return NSLocalizedString("Authentication", comment: "The title for the header of the authentication section")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .status:
            return 1
        case .authentication:
            return Authentication.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .status:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StatusTableViewCell", for: indexPath) as! StatusTableViewCell
            if let session = session {
                cell.stateLabel?.text = NSLocalizedString("Authenticated", comment: "The state label when an authenticated session exists")
                cell.environmentLabel?.text = session.environment.description
                cell.environmentLabel?.lineBreakMode = .byTruncatingMiddle
                cell.authenticationTokenLabel?.text = session.authenticationToken
                cell.authenticationTokenLabel?.lineBreakMode = .byTruncatingMiddle
                cell.userIDLabel?.text = session.userID
            } else {
                cell.stateLabel?.text = NSLocalizedString("Unauthenticated", comment: "The state text label an authenticated session does not exist")
                cell.environmentLabel?.text = NSLocalizedString("-", comment: "The environment label placeholder when an authenticated session does not exist")
                cell.authenticationTokenLabel?.text = NSLocalizedString("-", comment: "The authentication token label placeholder when an authenticated session does not exist")
                cell.userIDLabel?.text = NSLocalizedString("-", comment: "The user id label placeholder when an authenticated session does not exist")
            }
            return cell
        case .authentication:
            switch Authentication(rawValue: indexPath.row)! {
            case .login:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableViewCell", for: indexPath) as! LabelTableViewCell
                cell.label?.text = NSLocalizedString("Login", comment: "The label of the login cell")
                cell.label?.isEnabled = session == nil
                return cell
            case .refresh:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableViewCell", for: indexPath) as! LabelTableViewCell
                cell.label?.text = NSLocalizedString("Refresh", comment: "The label of the refresh cell")
                cell.label?.isEnabled = session != nil
                return cell
            case .logout:
                let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableViewCell", for: indexPath) as! LabelTableViewCell
                cell.label?.text = NSLocalizedString("Logout", comment: "The label of the logout cell")
                cell.label?.isEnabled = session != nil
                return cell
            }
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch Section(rawValue: indexPath.section)! {
        case .status:
            return true
        case .authentication:
            switch Authentication(rawValue: indexPath.row)! {
            case .login:
                return session == nil
            case .refresh:
                return session != nil
            case .logout:
                return session != nil
            }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section)! {
        case .status:
            if let session = session {
                UIPasteboard.general.string = "\(session.environment)|\(session.authenticationToken)|\(session.userID)"
            }
        case .authentication:
            switch Authentication(rawValue: indexPath.row)! {
            case .login:
                login()
            case .refresh:
                refresh()
            case .logout:
                logout()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func login() {
        var loginSignupViewController = api.loginSignupViewController()
        loginSignupViewController.delegate = self
        loginSignupViewController.environment = environment
        navigationController?.pushViewController(loginSignupViewController, animated: true)
    }

    private func refresh() {
        api.refresh(session: session!) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    let alert = UIAlertController(error: error) {
                        if case .unauthenticated(_, _) = error {
                            self.session = nil
                        }
                    }
                    self.present(alert, animated: true)
                case .success(let session):
                    self.session = session
                }
            }
        }
    }

    private func logout() {
        api.logout(session: session!) { error in
            DispatchQueue.main.async {
                if let error = error {
                    let alert = UIAlertController(error: error) {
                        self.session = nil
                    }
                    self.present(alert, animated: true)
                } else {
                    self.session = nil
                }
            }
        }
    }
}

extension RootTableViewController: TLoginSignupDelegate {
    func loginSignup(_ loginSignup: TLoginSignup, didCreateSession session: TSession) {
        DispatchQueue.main.async {
            self.environment = session.environment
            self.session = session
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension UIAlertController {
    convenience init(error: TError, handler: (() -> Void)? = nil) {
        self.init(title: NSLocalizedString("Error", comment: "The title of the error alert"), message: error.localizedDescription, preferredStyle: .alert)
        addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "The title of the OK button in the error alert"), style: .default) { _ in handler?() })
    }
}
