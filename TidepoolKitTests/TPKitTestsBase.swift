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

import XCTest
@testable import TidepoolKit

/// TODO: Set up a new test password?
let testEmail: String = "larry+kittest@tidepool.org"
let testPassword: String = "larry+kittest"
let testServer: TidepoolServer = .staging
var testDataset: TPDataset?

class TPKitTestsBase: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
    }
    
    func getTpKitSingleton() -> TidepoolKit {
        if let tpKit = TidepoolKit.sharedInstance { return tpKit }
        return TidepoolKit.init(logger: TPKitLoggerExample())!
    }
    
    func ensureLogin(completion: @escaping (TPSession) -> Void) {
        let tpKit = getTpKitSingleton()
        guard let session = tpKit.currentSession() else {
            tpKit.logIn(testEmail, password: testPassword, server: testServer) {
                result in
                switch result {
                case .success (let session):
                    NSLog("Logged into server creating session: \(session)")
                    completion(session)
                case .failure(let error):
                    XCTFail("Login failed: \(error)")
                }
            }
            return
        }
        completion(session)
    }

    func ensureDataset(completion: @escaping (TPDataset, TPSession) -> Void) {
        let tpKit = getTpKitSingleton()
        ensureLogin() {
            session in
            // if we have a dataset already, return that!
            if let dataset = testDataset, dataset.uploadId != nil {
                NSLog("Using existing dataset: \(dataset)")
                completion(dataset, session)
                return
            }
            let testDataSet = TPDataset(client: TPDatasetClient(name: "org.tidepool.tidepoolkittest", version: "1.0.0"), deduplicator: TPDeduplicator(type: .dataset_delete_origin))
            tpKit.getDataset(dataSet:testDataSet, user: session.user) {
                result in
                switch result {
                case .failure(let error):
                    XCTFail("failed to get dataset, error: \(error)")
                case .success(let dataset):
                    testDataset = dataset
                    NSLog("Dataset returned from getDataset: \(dataset)")
                    completion(dataset, session)
                }
            }
        }
    }

}
