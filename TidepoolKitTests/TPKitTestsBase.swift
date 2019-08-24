//
//  TPKitTestsBase.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
@testable import TidepoolKit

/// TODO: Set up a new test password?
let testEmail: String = "larry+kittest@tidepool.org"
let testPassword: String = "larry+kittest"
let testServer: TidepoolServer = .staging
var testDataset: TPDataset?
var tidepoolKit: TidepoolKit?

class TPKitTestsBase: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
    }
    
    func getTpKitSingleton() -> TidepoolKit {
        if let tpKit = tidepoolKit { return tpKit }
        if let tpKit = TidepoolKit.init(logger: TPKitLoggerExample()) {
            tidepoolKit = tpKit
            return tpKit
        }
        XCTFail("TidepoolKit singleton unexpectedly exists!")
        return TidepoolKit.sharedInstance
    }
    
    func ensureLogin(completion: @escaping (TPSession) -> Void) {
        let tpKit = getTpKitSingleton()
        guard let session = tpKit.currentSession else {
            tpKit.logIn(with: testEmail, password: testPassword, server: testServer) {
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
            tpKit.getDataset(for: session.user, matching: testDataSet) {
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
