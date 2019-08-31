//
//  TPKitTests14UserData_Basal.swift
//  TidepoolKitTests
//
//  Created by Larry Kenyon on 8/31/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TPKitTests14UserData_Basal: TPKitTestsBase {
    
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
    
    func createAutoBasalItem(_ rate: Double) -> TPDataBasal {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)!
        let sample = TPDataBasalAutomated(time: Date(), rate: rate, scheduleName: "test auto", duration: kOneDayTimeInterval, expectedDuration: kOneDayTimeInterval)
        sample?.origin = origin
        XCTAssertNotNil(sample, "\(#function) failed to create automated basal sample!")
        NSLog("created TPDataBasalAutomated: \(sample!)")
        return sample!
    }
    
    func createSchedBasalItem(_ rate: Double) -> TPDataBasal {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)!
        let sample = TPDataBasalScheduled(time: Date(), rate: rate, scheduleName: "test schedule", duration: kOneDayTimeInterval, expectedDuration: kOneDayTimeInterval)
        sample?.origin = origin
        XCTAssertNotNil(sample, "\(#function) failed to create scheduled basal sample!")
        NSLog("created TPDataBasalScheduled: \(sample!)")
        return sample!
    }

    func createTempBasalItem(_ rate: Double) -> TPDataBasal {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)!
        //let suppressed = TPDataSuppressed(
        let sample = TPDataBasalTemporary(time: Date(), duration: kOneDayTimeInterval, expectedDuration: kOneDayTimeInterval, rate: rate)
        sample?.origin = origin
        XCTAssertNotNil(sample, "\(#function) failed to create temporary basal sample!")
        NSLog("created TPDataBasalTemporary: \(sample!)")
        return sample!
    }
    
    func checkSerializeAndInitFromRaw(_ sample: TPDataBasal, deliveryType: TPBasalDeliveryType) {
        let asDict = sample.rawValue
        NSLog("serialized as dictionary: \(asDict)")
        var fromRaw: TPDataBasal?
        switch deliveryType {
        case .automated:
            fromRaw = TPDataBasalAutomated(rawValue: asDict)
        case .scheduled:
            fromRaw = TPDataBasalScheduled(rawValue: asDict)
        case .temp:
            fromRaw = TPDataBasalTemporary(rawValue: asDict)
        case .suspend:
            fromRaw = TPDataBasalSuppressed(rawValue: asDict)
        }
        XCTAssertNotNil(fromRaw)
        let valuesAreEqualivalent = stringAnyDictDiff(a1: asDict, a2: fromRaw!.rawValue)
        if !valuesAreEqualivalent {
            XCTFail("a1 and a2 differ!")
        }
    }
    
    func test11CreateAndUploadBasalDataItems() {
        
        let autoSample: TPDataBasal = createAutoBasalItem(2.55)
        checkSerializeAndInitFromRaw(autoSample, deliveryType: .automated)
        
        let schedSample: TPDataBasal = createSchedBasalItem(1.50)
        checkSerializeAndInitFromRaw(schedSample, deliveryType: .scheduled)
        
        let tempSample: TPDataBasal = createTempBasalItem(0.55)
        checkSerializeAndInitFromRaw(autoSample, deliveryType: .temp)

        let expectation = self.expectation(description: "post of basal sample data completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin/Dataset...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            
            tpKit.putData(samples: [autoSample, schedSample, tempSample], into: dataset) {
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
    
    func test12GetDeviceData_Basal() {
        let expectation = self.expectation(description: "Fetch of basal data complete")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            XCTAssert(tpKit.isLoggedIn())
            // last hour:
            let end = Date()
            let start = end.addingTimeInterval(-self.kOnehourTimeInterval)
            // around a particular date
            //let dateStr = "2017-04-21T03:28:30.000Z"
            //let itemDate = self.dateFromStr(dateStr)
            //let end =  itemDate.addingTimeInterval(self.kOnehourTimeInterval)
            //let start = itemDate.addingTimeInterval(-self.kOnehourTimeInterval)
            tpKit.getData(for: session.user, startDate: start, endDate: end, objectTypes: "basal") {
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
