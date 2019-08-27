//
//  TPKitTestsBase.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

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
    
    var isRunningOnDevice: Bool = {
        #if targetEnvironment(simulator)
        return false
        #else
        return true
        #endif
    }()
    
    func getTpKitSingleton() -> TidepoolKit {
        if isRunningOnDevice {
            NSLog("Testing on device in context of example app!")
        }
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
    
    // utility method to check two json dicts for equality... may be useful for comparing round trips of data, but will need to be extended for exceptions (e.g., service adds in id)
    func stringAnyDictDiff(a1: [String: Any], a2: [String: Any]) -> Bool {
        
        func anyDiff(v1: Any, v2: Any, key: String) -> Bool {
            if type(of: v1) != type(of: v2) {
                print("a2 key '\(key)' value '\(v2)' does not type of a1 value '\(v1)'")
                return false
            }
            var result = true
            if let v1 = v1 as? Int, let v2 = v2 as? Int {
                if v1 != v2 { result = false }
            } else if let v1 = v1 as? String, let v2 = v2 as? String {
                if v1 != v2 { result = false }
            } else if let v1 = v1 as? Double, let v2 = v2 as? Double {
                if v1 != v2 { result = false }
            } else {
                print("extend type compare for type '\(type(of: v1))'!")
            }
            if result == false {
                print("a2 key '\(key)' value '\(v2)' does not match a1 value '\(v1)'")
            }
            return result
        }
        
        var result = true
        for (key, v1) in a1 {
            let v2 = a2[key]
            if v2 == nil {
                print("a2 missing value \(v1) for key \(key)")
                result = false
            } else if let v1 = v1 as? [String: Any], let v2 = v2 as? [String: Any] {
                if !stringAnyDictDiff(a1: v1, a2: v2) {
                    result = false
                }
            } else if let v1 = v1 as? [[String: Any]], let v2 = v2 as? [[String: Any]] {
                if v1.count != v2.count {
                    print("a2 array \(v2) for \(key) differs in count!")
                    result = false
                } else {
                    for i in 0..<v1.count {
                        if !stringAnyDictDiff(a1: v1[i], a2: v2[i]) {
                            result = false
                        }
                    }
                }
            } else {
                if !anyDiff(v1: v1, v2: v2!, key: key) {
                    result = false
                }
            }
        }
        for (key, v2) in a2 {
            let v1 = a1[key]
            if v1 == nil {
                print("a1 missing value \(v2) for key \(key)")
                result = false
            }
        }
        return result
    }

}
