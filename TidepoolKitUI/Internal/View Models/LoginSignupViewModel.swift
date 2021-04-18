//
//  LoginSignupViewModel.swift
//  TidepoolKitUI
//
//  Created by Darin Krauss on 4/17/21.
//  Copyright © 2021 Tidepool Project. All rights reserved.
//

import TidepoolKit

class LoginSignupViewModel: TLoginSignup {
    weak var loginSignupDelegate: TLoginSignupDelegate?
    var environment: TEnvironment?

    private var api: TAPI

    init(api: TAPI) {
        self.api = api
    }

    var environments: [TEnvironment] { api.environments }

    var resolvedEnvironment: TEnvironment { environment ?? environments.first! }

    func login(email: String, password: String, completion: @escaping (Error?) -> Void) {
        api.login(environment: resolvedEnvironment, email: email, password: password) { result in
            switch result {
            case .failure(let error):
                completion(error)
            case .success(let session):
                self.loginSignupDelegate?.loginSignup(self, didCreateSession: session, completion: completion)
            }
        }
    }

    func cancel() {
        loginSignupDelegate?.loginSignupCancelled()
    }
}
