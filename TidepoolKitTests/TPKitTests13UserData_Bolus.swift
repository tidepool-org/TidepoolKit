//
//  TPKitTests13UserData_Bolus.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPKitTests13UserData_Bolus: TPKitTestsBase {

    let kOneWeekTimeInterval: TimeInterval = 60*60*24*7
    func test12GetDeviceData_Bolus() {
        let expectation = self.expectation(description: "Fetch of bolus data complete")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            XCTAssert(tpKit.isLoggedIn())
            //let end = Date()
            //let start = end.addingTimeInterval(-self.kOneWeekTimeInterval)
            tpKit.getData(for: session.user, startDate: .distantPast, endDate: .distantFuture, objectTypes: "bolus") {
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

}
