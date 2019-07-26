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

class TPKitTests10UserData: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test11UploadId() {
        let expectation = self.expectation(description: "Upload id fetch/create successful")
        // first log out if logged in to force clear of upload id...
        let tpKit = TidepoolKit.sharedInstance
        NSLog("\(#function): starting with logout...")
        // next, log in, and then try configuring upload id: this will fetch a current id, or create one if a current id does not exist. Note: there is no way to force delete of an upload id, so a new account would be needed to test the create!
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            result in
            NSLog("\(#function): ensureLogin completed... with result: \(result)")
            tpKit.resetUploadId()
            XCTAssert(tpKit.currentUploadId() == nil)
            // first test with default dataset...
            tpKit.configureUploadId() {
                XCTAssert(tpKit.currentUploadId() != nil)
                
                // second, test with a different dataset...
                tpKit.resetUploadId()
                let testDataSet = TPDataset()
                // override default name to force a one-time create, and test override logic...
                testDataSet.clientName = "org.tidepool.tidepoolkittest"
                // NOTE: override of deduplicator passes, and service passes down a new dataset with this deduplicator type, but subsequent queries of datasets do not return the newly created one, so this currently will always result in a new upload id being created...
                //testDataSet.deduplicator = .device_deactivate_hash
                tpKit.configureUploadId(dataSet:testDataSet) {
                    XCTAssert(tpKit.currentUploadId() != nil)
                    expectation.fulfill()
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    let kOneWeekTimeInterval: TimeInterval = 60*60*24*7
    func test12GetUserData() {
        let expectation = self.expectation(description: "Fetch of user data successful")
        let tpKit = TidepoolKit.sharedInstance
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            result in
            NSLog("\(#function): ensureLogin completed... with result: \(result)")
            XCTAssert(tpKit.isLoggedIn())
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getUserData(start, endDate: end) {
                result in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data fetch!")
                    XCTFail()
                case .success(let userDataArray):
                    NSLog("\(#function) fetched \(userDataArray.userData.count) items!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test13DeletetUserData() {
        let expectation = self.expectation(description: "Delete of user data successful")
        let tpKit = TidepoolKit.sharedInstance
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            result in
            NSLog("\(#function): ensureLogin completed... with result: \(result)")
            XCTAssert(tpKit.isLoggedIn())
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getUserData(start, endDate: end) {
                result in
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data fetch!")
                    XCTFail()
                case .success(let userDataArray):
                    NSLog("\(#function) fetched \(userDataArray.userData.count) items!")
                    tpKit.deleteUserData(userDataArray) {
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

    let TestCbgOriginPayload1: [String: Any] = [
        "sourceRevision": [
            "source": [
                "name": "JoJo Loop",
                "bundleIdentifier": "com.8Q7535T65L.loopkit.Loop"
            ],
            "productType": "iPhone10,1",
            "operatingSystemVersion": "12.3.0",
            "version": "55"
        ],
        "device": [
            "udiDeviceIdentifier": "00386270000385",
            "name": "CGMBLEKit",
            "softwareVersion": "20.0",
            "model": "G6",
            "manufacturer": "Dexcom"
        ]
    ]

    let TestCbgPayload1: [String: Any] = [
        "HKMetadataKeySyncIdentifier" : "80XBG2972576",
        "HKMetadataKeySyncVersion" : 1,
        "com.loudnate.GlucoseKit.HKMetadataKey.GlucoseIsDisplayOnly" : 0
    ]

    let TestCbgOriginPayload2: [String: Any] = [
        "sourceRevision" : [
            "operatingSystemVersion" : "12.2.0",
            "source" : [
                "bundleIdentifier" : "com.dexcom.G6",
                "name" : "Dexcom G6"
            ],
            "productType" : "iPhone10,6",
            "version" : "15631"
        ]
    ]

    let TestCbgPayload2: [String: Any] = [
        "Trend Arrow" : "Flat",
        "Transmitter Time" : "2019-04-06T23:55:06.000Z",
        "HKDeviceName" : "10386270000221",
        "Trend Rate" : -0.10000000000000001,
        "HKTimeZone" : "America/Los_Angeles",
        "Status" : "IN_RANGE"
    ]

    func test14PostCbgDataItem() {
        let expectation = self.expectation(description: "Post of user cbg data successful")
        let tpKit = TidepoolKit.sharedInstance
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            result in
            NSLog("\(#function): ensureLogin completed... with result: \(result)")
            XCTAssert(tpKit.isLoggedIn())
            let newId = UUID.init().uuidString
            let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: "service", payload: self.TestCbgOriginPayload2)!
            let payload = self.TestCbgPayload2
            guard let cbgSample = TPDataCbg(time: Date(), value: 90, units: .milligramsPerDeciliter) else {
                NSLog("\(#function) failed to create cbg sample!")
                XCTFail()
                return
            }
            cbgSample.origin = origin
            cbgSample.payload = payload
            NSLog("created TPDataCbg: \(cbgSample.debugDescription)")
            let tpDataArray = TPUserDataArray([cbgSample])
            tpKit.putUserData(tpDataArray) {
                result,arg  in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data upload!")
                    XCTFail()
                case .success:
                    NSLog("\(#function) upload succeeded!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func createCarbItem(_ net: Double) -> TPDataFood? {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: "service", payload: nil)!
        let foodSample = TPDataFood(nil, time: Date(), carbs: net)
        foodSample?.origin = origin
        XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
        NSLog("created TPDataFood: \(foodSample!.debugDescription)")
        return foodSample
    }
    
    func test15CreateCarbDataItem() {
        let foodSample = createCarbItem(30)
        XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")
        let asDict = foodSample!.rawValue
        NSLog("serialized as dictionary: \(asDict)")
    }
    
    func test16PostCarbDataItem() {
        let expectation = self.expectation(description: "Post of user carb data successful")
        let tpKit = TidepoolKit.sharedInstance
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            result in
            NSLog("\(#function): ensureLogin completed... with result: \(result)")
            XCTAssert(tpKit.isLoggedIn())

            let foodSample = self.createCarbItem(30)
            XCTAssertNotNil(foodSample, "\(#function) failed to create food sample!")

            let tpDataArray = TPUserDataArray([foodSample!])
            tpKit.putUserData(tpDataArray) {
                result,arg  in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data upload!")
                    XCTFail()
                case .success:
                    NSLog("\(#function) upload succeeded!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    //
    // MARK: - Helper functions
    //
    
    func ensureLogin(completion: @escaping (Result<TPUser, TidepoolKitError>) -> Void) {
        let tpKit = TidepoolKit.sharedInstance
        tpKit.switchToServer(testService)
        guard let user = tpKit.loggedInUser() else {
            tpKit.logIn(testEmail, password: testPassword) {
                result in
                switch result {
                case .success:
                    completion(result)
                case .failure(let error):
                    XCTFail("Login failed: \(error)")
                }
            }
            return
        }
        completion(.success(user))
    }


}
