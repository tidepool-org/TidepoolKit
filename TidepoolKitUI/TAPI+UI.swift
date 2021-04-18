//
//  TAPI+UI.swift
//  TidepoolKitUI
//
//  Created by Darin Krauss on 1/20/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import TidepoolKit

/// The delegate for the Tidepool login and signup UI.
public protocol TLoginSignupDelegate: AnyObject {

    /// Notify the delegate that the login or signup was successful and a session was created.
    ///
    /// - Parameters:
    ///   - loginSignup: The login signup that invoked the delegate
    ///   - session: The newly created session
    ///   - completion: The completion function to invoke with any error.
    func loginSignup(_ loginSignup: TLoginSignup, didCreateSession session: TSession, completion: @escaping (Error?) -> Void)

    /// Notify the delegate that the login or signup was cancelled.
    func loginSignupCancelled()
}

/// The Tidepool login and signup UI requirements.
public protocol TLoginSignup {

    /// The delegate to this login signup
    var loginSignupDelegate: TLoginSignupDelegate? { get set }

    /// The environment to use for this login signup
    var environment: TEnvironment? { get set }
}

public extension TAPI {

    /// Create the login and signup view controller.
    func loginSignupViewController() -> (UIViewController & TLoginSignup) { LoginSignupNavigationController(api: self) }
}
