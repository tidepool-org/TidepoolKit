//
//  LoginSignupViewModel.swift
//  TidepoolKitUI
//
//  Created by Darin Krauss on 4/17/21.
//  Copyright © 2021 Tidepool Project. All rights reserved.
//

import TidepoolKit

public class LoginSignupViewModel: TLoginSignup {
    public weak var loginSignupDelegate: TLoginSignupDelegate?
    public var environment: TEnvironment?

    private var api: TAPI

    public init(api: TAPI) {
        self.api = api
    }

    var environments: [TEnvironment] { api.environments }

    var defaultEnvironment: TEnvironment? { api.defaultEnvironment }

    var resolvedEnvironment: TEnvironment { environment ?? defaultEnvironment ?? environments.first! }

    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        api.login(environment: resolvedEnvironment, email: email, password: password) { error in
            if let error {
                completion(error)
                return
            }
            self.loginSignupDelegate?.loginSignupDidComplete(completion: completion)
        }
    }

    func cancel() {
        loginSignupDelegate?.loginSignupCancelled()
    }
}
