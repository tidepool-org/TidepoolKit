//
//  TPKitTests10UserData.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPKitTests10UserData: TPKitTestsBase {

    func test11_1GetDataset() {
        let expectation = self.expectation(description: "dataset fetches/creates completed")
        let tpKit = getTpKitSingleton()
        NSLog("\(#function): starting with logout...")
        // next, log in, and then try configuring upload id: this will fetch a current id, or create one if a current id does not exist. Note: there is no way to force delete of an upload id, so a new account would be needed to test the create!
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            // first test with default dataset...
            tpKit.getDataset(for: session.user, matching: TPDataset()) {
                result in
                if case .failure(let error) = result {
                    expectation.fulfill()
                    XCTFail("failed to get dataset, error: \(error)")
                }
                
                // second, test with test dataset...
                let testDataSet = TPDataset(client: TPDatasetClient(name: "org.tidepool.tidepoolkittest", version: "1.0.0"), deduplicator: TPDeduplicator(type: .dataset_delete_origin))
                tpKit.getDataset(for: session.user, matching: testDataSet) {
                    result in
                    expectation.fulfill()
                    if case .failure(let error) = result {
                        XCTFail("failed to get dataset, error: \(error)")
                    }
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test11_1aGetDatasetOffline() {
        let expectation = self.expectation(description: "dataset fetches/creates failed with offline")
        let tpKit = getTpKitSingleton()
        NSLog("\(#function): starting with logout...")
        // next, log in, and then try configuring upload id: this will fetch a current id, or create one if a current id does not exist. Note: there is no way to force delete of an upload id, so a new account would be needed to test the create!
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            self.configureOffline(true)
            // test with default dataset...
            tpKit.getDataset(for: session.user, matching: TPDataset()) {
                result in
                expectation.fulfill()
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "dataset fetch")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test11_2GetDatasets() {
        let expectation = self.expectation(description: "datasets fetch completed")
        let tpKit = getTpKitSingleton()
        NSLog("\(#function): starting with logout...")
        // next, log in, and then try configuring upload id: this will fetch a current id, or create one if a current id does not exist. Note: there is no way to force delete of an upload id, so a new account would be needed to test the create!
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            // first test with default dataset...
            tpKit.getDatasets(for: session.user) {
                result in
                expectation.fulfill()
               if case .failure(let error) = result {
                    XCTFail("failed to get datasets, error: \(error)")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test11_2GetDatasetsOffline() {
        let expectation = self.expectation(description: "datasets fetch failed with offline")
        let tpKit = getTpKitSingleton()
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            self.configureOffline(true)
            // test with default dataset...
            tpKit.getDatasets(for: session.user) {
                result in
                expectation.fulfill()
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "datasets fetch")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test12GetUserData() {
        let expectation = self.expectation(description: "user data fetch completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            XCTAssert(tpKit.isLoggedIn())
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getData(for: session.user, startDate: start, endDate: end) {
                result in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data fetch!")
                    XCTFail()
                case .success(let userDataArray):
                    NSLog("\(#function) fetched \(userDataArray.count) items!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test12aGetUserDataOffline() {
        let expectation = self.expectation(description: "user data fetch failed with offline")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            self.configureOffline(true)
            XCTAssert(tpKit.isLoggedIn())
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getData(for: session.user, startDate: start, endDate: end) {
                result in
                expectation.fulfill()
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "user data fetch")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test13_1_DeleteUserData() {
        let expectation = self.expectation(description: "user data get, delete calls completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getData(for: session.user, startDate: start, endDate: end) {
                result in
                switch result {
                case .failure:
                    expectation.fulfill()
                    NSLog("\(#function) failed user data fetch!")
                    XCTFail()
                case .success(let userDataArray):
                    let itemCount = userDataArray.count
                    NSLog("\(#function) fetched \(itemCount) items!")
                    guard itemCount > 0 else {
                        expectation.fulfill()
                        NSLog("\(#function) no data to delete, pass test!")
                        return
                    }
                    // convert existing TPDeviceData items into TPDeleteItems
                    var deleteItems: [TPDeleteItem] = []
                    for item in userDataArray {
                        if let deleteItem = TPDeleteItem(item) {
                            deleteItems.append(deleteItem)
                        }
                    }
                    // and delete...
                    tpKit.deleteData(samples: deleteItems, from: dataset) {
                        result in
                        expectation.fulfill()
                        switch result {
                        case .failure:
                            NSLog("\(#function) failed delete user data!")
                            XCTFail()
                        case .success:
                            NSLog("\(#function) delete succeeded!")
                        }
                    }
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    /// Test passing a bunch of origin ids, where data doesn't exist...
    func test13_2_DeleteUserData() {
        let expectation = self.expectation(description: "user data delete call completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            var deleteItemArray: [TPDeleteItem] = []
            for _ in 1...5 {
                let id = UUID().uuidString
                if let deleteItem = TPDeleteItem(originId: id) {
                    deleteItemArray.append(deleteItem)
                }
            }
            XCTAssert(deleteItemArray.count == 5)
            for _ in 1...5 {
                let id = UUID().uuidString
                let origin = TPDataOrigin(id: id)
                if let deleteItem = TPDeleteItem(origin: origin) {
                    deleteItemArray.append(deleteItem)
                }
            }
            XCTAssert(deleteItemArray.count == 10)
            tpKit.deleteData(samples: deleteItemArray, from: dataset) {
                result in
                expectation.fulfill()
                switch result {
                case .failure(let error):
                    if case .dataNotFound = error {
                        // Only valid error is 404. Some instances of server just return 200.
                        NSLog("\(#function) delete returned dataNotFound!")
                    } else {
                        NSLog("\(#function) failed delete user data!")
                        XCTFail()
                    }
                case .success:
                    NSLog("\(#function) delete succeeded!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test13_2a_DeleteUserDataOffline() {
        let expectation = self.expectation(description: "user data delete call failed with offline")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            var deleteItemArray: [TPDeleteItem] = []
            for _ in 1...5 {
                let id = UUID().uuidString
                if let deleteItem = TPDeleteItem(originId: id) {
                    deleteItemArray.append(deleteItem)
                }
            }
            self.configureOffline(true)
            tpKit.deleteData(samples: deleteItemArray, from: dataset) {
                result in
                expectation.fulfill()
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "delete user data")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled. If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

}
