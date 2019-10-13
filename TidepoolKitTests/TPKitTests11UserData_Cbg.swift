//
//  TPKitTests11UserData_Cbg.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPKitTests11UserData_Cbg: TPKitTestsBase {

    let TestCbgOriginPayload1 = TPDataPayload([
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
    ])

    let TestCbgPayload1 = TPDataPayload([
        "HKMetadataKeySyncIdentifier" : "80XBG2972576",
        "HKMetadataKeySyncVersion" : 1,
        "com.loudnate.GlucoseKit.HKMetadataKey.GlucoseIsDisplayOnly" : 0
    ])

    let TestCbgOriginPayload2 = TPDataPayload([
        "sourceRevision" : [
            "operatingSystemVersion" : "12.2.0",
            "source" : [
                "bundleIdentifier" : "com.dexcom.G6",
                "name" : "Dexcom G6"
            ],
            "productType" : "iPhone10,6",
            "version" : "15631"
        ]
    ])

    let TestCbgPayload2 = TPDataPayload([
        "Trend Arrow" : "Flat",
        "Transmitter Time" : "2019-04-06T23:55:06.000Z",
        "HKDeviceName" : "10386270000221",
        "Trend Rate" : -0.10000000000000001,
        "HKTimeZone" : "America/Los_Angeles",
        "Status" : "IN_RANGE"
    ])

    func test14PostCbgDataItem() {
        let expectation = self.expectation(description: "post of user cbg data completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            let newId = UUID.init().uuidString
            let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: self.TestCbgOriginPayload2)
            let payload = self.TestCbgPayload2
            let cbgSample = TPDataCbg(time: Date(), value: 90, units: .milligramsPerDeciliter)
            cbgSample.origin = origin
            cbgSample.payload = payload
            NSLog("created TPDataCbg: \(cbgSample)")
            tpKit.putData(samples: [cbgSample], into: dataset) {
                result  in
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

    func test14aPostCbgDataItemOffline() {
        let expectation = self.expectation(description: "post of user cbg failed with offline")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            let newId = UUID.init().uuidString
            let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: self.TestCbgOriginPayload2)
            let payload = self.TestCbgPayload2
            let cbgSample = TPDataCbg(time: Date(), value: 90, units: .milligramsPerDeciliter)
            cbgSample.origin = origin
            cbgSample.payload = payload
            NSLog("created TPDataCbg: \(cbgSample)")
            self.configureOffline(true)
            tpKit.putData(samples: [cbgSample], into: dataset) {
                result  in
                expectation.fulfill()
                self.configureOffline(false)
                self.checkForOfflineResult(result, fetchType: "cbg data post")
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test15PostCbgDataItemWithReject() {
        let expectation = self.expectation(description: "post of user cbg data with service rejection")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            let newId = UUID.init().uuidString
            let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: self.TestCbgOriginPayload2)
            let payload = self.TestCbgPayload2
            let cbgSample = TPDataCbg(time: Date(), value: 90, units: .milligramsPerDeciliter)
            cbgSample.origin = origin
            cbgSample.payload = payload
            NSLog("created TPDataCbg: \(cbgSample)")
            // now create a similar cbg item that is out of bounds...
            let cbgSample2 = TPDataCbg(time: Date().addingTimeInterval(-5), value: 1100, units: .milligramsPerDeciliter)
            tpKit.putData(samples: [cbgSample, cbgSample2], into: dataset) {
                result  in
                expectation.fulfill()
                switch result {
                case .failure (let error):
                    NSLog("\(#function) failed user data upload!")
                    switch error {
                    case .badRequest(let badSampleIndexArray, let response):
                        guard let badSampleIndexArray = badSampleIndexArray else {
                            XCTFail("expected bad sample array, got nil!")
                            return
                        }
                        guard badSampleIndexArray.count == 1 else {
                            XCTFail("expected bad sample array to have exactly 1 entry: \(badSampleIndexArray)")
                            return
                        }
                        guard badSampleIndexArray.first! == 1 else {
                            XCTFail("expected bad sample array item to be sample 1: \(badSampleIndexArray)")
                            return
                        }
                        NSLog("Received expected bad sample array: \(badSampleIndexArray)")
                        if let dataStr = String(data: response, encoding: .ascii) {
                            NSLog("parsed from response data: \(dataStr)")
                        }
                    default:
                        XCTFail("expected .badRequest error, got \(error)")
                    }
                case .success:
                    NSLog("\(#function) upload succeeded!")
                    XCTFail("expected upload failure!")
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

}
