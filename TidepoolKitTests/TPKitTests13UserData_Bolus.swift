//
//  TPKitTests13UserData_Bolus.swift
//  TidepoolKitTests
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPKitTests13UserData_Bolus: TPKitTestsBase {

    func dateFromStr(_ str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "GMT")
        guard let result = dateFormatter.date(from: str) else {
            XCTFail("unable to parse date string: \(str)")
            return Date()
        }
        return result
    }
    
    func createNormalBolusItem(_ normal: Double) -> TPDataBolus {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)
        let normalSample = TPDataBolusNormal(time: Date(), normal: normal)
        normalSample.origin = origin
        NSLog("created TPDataBolusNormal: \(normalSample)")
        return normalSample
    }
    
    func createExtendedBolusItem(_ extended: Double, duration: TimeInterval) -> TPDataBolus {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)
        let extendedSample = TPDataBolusExtended(time: Date(), extended: extended, duration: duration)
        extendedSample.origin = origin
        NSLog("created TPDataBolusExtended: \(extendedSample)")
        return extendedSample
    }

    func createCombinationBolusItem(normal: Double, expectedNormal: Double? = nil, extended: Double, expectedExtended: Double? = nil, duration: TimeInterval, expectedDuration: TimeInterval? = nil) -> TPDataBolus {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)
        let combinationSample = TPDataBolusCombination(time: Date(), normal: normal, expectedNormal: expectedNormal, extended: extended, expectedExtended: expectedExtended, duration: duration, expectedDuration: expectedDuration)
        combinationSample.origin = origin
        NSLog("created TPDataBolusCombination: \(combinationSample)")
        return combinationSample
    }

    func checkSerializeAndInitFromRaw(_ sample: TPDataBolus, subType: TPBolusSubType) {
        let asDict = sample.rawValue
        NSLog("serialized as dictionary: \(asDict)")
        var fromRaw: TPDataBolus?
        switch subType {
        case .normal:
            fromRaw = TPDataBolusNormal(rawValue: asDict)
        case .extended:
            fromRaw = TPDataBolusExtended(rawValue: asDict)
        case .combination:
            fromRaw = TPDataBolusCombination(rawValue: asDict)
        }
        XCTAssertNotNil(fromRaw)
        XCTAssertTrue(stringAnyDictDiff(a1: asDict, a2: fromRaw!.rawValue))
    }

    func test11CreateAndUploadBolusDataItems() {
        
        let normalSample: TPDataBolus = createNormalBolusItem(2.55)
        checkSerializeAndInitFromRaw(normalSample, subType: .normal)
        
        let extendedSample = createExtendedBolusItem(4.0, duration: 60*4)
        checkSerializeAndInitFromRaw(extendedSample, subType: .extended)

        let combinationSample = createCombinationBolusItem(normal: 1.5, expectedNormal: 4.5, extended: 0.0, expectedExtended: 2.0, duration: 0, expectedDuration: 60*6)
        checkSerializeAndInitFromRaw(combinationSample, subType: .combination)
        
        let expectation = self.expectation(description: "post of bolus sample data completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin/Dataset...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            
            tpKit.putData(samples: [normalSample, extendedSample, combinationSample], into: dataset) {
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
        waitForExpectations(timeout: 20.0, handler: nil)
    }

    func test12GetDeviceData_Bolus() {
        let expectation = self.expectation(description: "Fetch of bolus data complete")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            XCTAssert(tpKit.isLoggedIn())
            // last hour:
            let end = Date()
            let start = end.addingTimeInterval(-self.oneHourTimeInterval)
            // around a particular date
            //let dateStr = "2017-04-21T03:28:30.000Z"
            //let itemDate = self.dateFromStr(dateStr)
            //let end =  itemDate.addingTimeInterval(self.onehourTimeInterval)
            //let start = itemDate.addingTimeInterval(-self.onehourTimeInterval)
            tpKit.getData(for: session.user, startDate: start, endDate: end, objectTypes: "bolus") {
                result in
                expectation.fulfill()
                switch result {
                case .failure:
                    NSLog("\(#function) failed user data fetch!")
                    XCTFail()
                case .success(let userDataArray):
                    NSLog("\(#function) fetched \(userDataArray.count) items!")
                    for i in 0..<userDataArray.count {
                        NSLog("item \(i):")
                        NSLog("\(userDataArray[i])")
                    }
                }
            }
        }
        // Wait 20.0 seconds until expectation has been fulfilled (sometimes staging takes almost 10 seconds). If not, fail.
        waitForExpectations(timeout: 20.0, handler: nil)
    }

}
