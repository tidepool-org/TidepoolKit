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
    private var environment: TEnvironment? {
        didSet {
            UserDefaults.standard.environment = environment
            tableView.reloadData()
        }
    }
    private var session: TSession? {
        didSet {
            UserDefaults.standard.session = session
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

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.session = UserDefaults.standard.session
        self.environment = UserDefaults.standard.environment
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(TextButtonTableViewCell.self, forCellReuseIdentifier: TextButtonTableViewCell.className)
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

    private let defaultStatusLabelText = NSLocalizedString("-", comment: "The default status label text")

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section)! {
        case .status:
            let cell = tableView.dequeueReusableCell(withIdentifier: StatusTableViewCell.className, for: indexPath) as! StatusTableViewCell
            cell.environmentLabel?.text = environment?.description ?? defaultStatusLabelText
            if let session = session {
                cell.stateLabel?.text = NSLocalizedString("Authenticated", comment: "The state label when an authenticated session exists")
                cell.authenticationTokenLabel?.text = session.authenticationToken
                cell.userIDLabel?.text = session.userID
            } else {
                cell.stateLabel?.text = NSLocalizedString("Unauthenticated", comment: "The state text label an authenticated session does not exist")
                cell.authenticationTokenLabel?.text = defaultStatusLabelText
                cell.userIDLabel?.text = defaultStatusLabelText
            }
            return cell
        case .authentication:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextButtonTableViewCell.className, for: indexPath) as! TextButtonTableViewCell
            switch Authentication(rawValue: indexPath.row)! {
            case .login:
                cell.textLabel?.text = NSLocalizedString("Login", comment: "The text label of the authentication login cell")
                cell.accessoryType = .disclosureIndicator
                cell.isEnabled = session == nil
                return cell
            case .refresh:
                cell.textLabel?.text = NSLocalizedString("Refresh", comment: "The text label of the authentication refresh cell")
                cell.isEnabled = session != nil
                return cell
            case .logout:
                cell.textLabel?.text = NSLocalizedString("Logout", comment: "The text label of the authentication logout cell")
                cell.isEnabled = session != nil
            }
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch Section(rawValue: indexPath.section)! {
        case .status:
            return false
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
            break
        case .authentication:
            let cell = tableView.cellForRow(at: indexPath) as! TextButtonTableViewCell
            cell.isLoading = true
            switch Authentication(rawValue: indexPath.row)! {
            case .login:
                authenticationLogin() {
                    cell.isLoading = false
                }
            case .refresh:
                authenticationRefresh() {
                    cell.isLoading = false
                }
            case .logout:
                authenticationLogout() {
                    cell.isLoading = false
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func authenticationLogin(completion: @escaping () -> Void) {
        var loginSignupViewController = api.loginSignupViewController()
        loginSignupViewController.delegate = self
        loginSignupViewController.environment = environment
        navigationController?.pushViewController(loginSignupViewController, animated: true)
        completion()
    }

    private func authenticationRefresh(completion: @escaping () -> Void) {
        api.refresh(session: session!) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    let alert = UIAlertController(error: error) {
                        if case .requestNotAuthenticated(_, _) = error {
                            self.session = nil
                        }
                    }
                    self.present(alert, animated: true)
                case .success(let session):
                    self.session = session
                }
                completion()
            }
        }
    }

    private func authenticationLogout(completion: @escaping () -> Void) {
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
                completion()
            }
        }
    }
}

extension RootTableViewController: TLoginSignupDelegate {
    func loginSignup(_ loginSignup: TLoginSignup, didCreateSession session: TSession) -> Error? {
        self.environment = session.environment
        self.session = session
        navigationController?.popViewController(animated: true)
        return nil
    }
}
