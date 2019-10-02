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
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)
        let scheduleName = "test schedule"
        let duration = kOneDayTimeInterval
        let expectedDuration = kOneDayTimeInterval
        let sample = TPDataBasalAutomated(time: Date(), rate: rate, scheduleName: scheduleName, duration: duration, expectedDuration: expectedDuration)
        sample.origin = origin
        XCTAssert(sample.deliveryType == .automated)
        XCTAssert(sample.rate == rate)
        XCTAssert(sample.scheduleName == scheduleName)
        XCTAssert(sample.duration == duration)
        XCTAssert(sample.expectedDuration == expectedDuration)
        NSLog("created TPDataBasalAutomated: \(sample)")
        return sample
    }
    
    func createSchedBasalItem(_ rate: Double) -> TPDataBasal {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)
        let scheduleName = "test schedule"
        let duration = kOneDayTimeInterval
        let expectedDuration = kOneDayTimeInterval
        let sample = TPDataBasalScheduled(time: Date(), rate: rate, scheduleName: scheduleName, duration: duration, expectedDuration: expectedDuration)
        sample.origin = origin
        XCTAssert(sample.deliveryType == .scheduled)
        XCTAssert(sample.rate == rate)
        XCTAssert(sample.scheduleName == scheduleName)
        XCTAssert(sample.duration == duration)
        XCTAssert(sample.expectedDuration == expectedDuration)
        NSLog("created TPDataBasalScheduled: \(sample)")
        return sample
    }

    func createTempBasalItem(_ rate: Double) -> TPDataBasal {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)
        let duration = kOneDayTimeInterval
        let expectedDuration = kOneDayTimeInterval
        let suppressed = TPDataSuppressed(.scheduled, rate: 0.25, scheduleName: "Standard")
        let sample = TPDataBasalTemporary(time: Date(), duration: duration, expectedDuration: expectedDuration, rate: rate, suppressed: suppressed)
        sample.origin = origin
        XCTAssert(sample.deliveryType == .temp)
        XCTAssert(sample.rate == rate)
        XCTAssert(sample.duration == duration)
        XCTAssert(sample.expectedDuration == expectedDuration)
        NSLog("created TPDataBasalTemporary: \(sample)")
        return sample
    }
    
    func createSuspendBasalItem(_ deliveryType: TPBasalDeliveryType, rate: Double) -> TPDataBasal {
        let newId = UUID.init().uuidString
        let origin = TPDataOrigin(id: newId, name: "org.tidepool.tidepoolKitTest", type: .service, payload: nil)
        let duration = kOneHourTimeInterval
        let expectedDuration = kOneDayTimeInterval
        let suppressed = TPDataSuppressed(deliveryType, rate: 0.25, scheduleName: "Standard")
        let sample = TPDataBasalSuppressed(time: Date(), duration: duration, expectedDuration: expectedDuration, suppressed: suppressed)
        sample.origin = origin
        XCTAssertNotNil(sample, "\(#function) failed to create temporary basal sample!")
        XCTAssert(sample.deliveryType == .suspend)
        XCTAssert(sample.duration == duration)
        XCTAssert(sample.expectedDuration == expectedDuration)
        NSLog("created TPDataBasalSuppressed: \(sample)")
        return sample
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
    
    func test11CreateAndSerializeBasalDataItems() {
        let autoSample: TPDataBasal = createAutoBasalItem(2.55)
        checkSerializeAndInitFromRaw(autoSample, deliveryType: .automated)
        
        let schedSample: TPDataBasal = createSchedBasalItem(1.50)
        checkSerializeAndInitFromRaw(schedSample, deliveryType: .scheduled)
        
        let tempSample: TPDataBasal = createTempBasalItem(0.55)
        checkSerializeAndInitFromRaw(tempSample, deliveryType: .temp)
        
        let suspendSample: TPDataBasal = createSuspendBasalItem(.scheduled, rate: 0.25)
        checkSerializeAndInitFromRaw(suspendSample, deliveryType: .suspend)
    }

    func test12CreateAndUploadBasalDataItems() {
        
        let autoSample: TPDataBasal = createAutoBasalItem(2.55)
        checkSerializeAndInitFromRaw(autoSample, deliveryType: .automated)
        
        let schedSample: TPDataBasal = createSchedBasalItem(1.50)
        checkSerializeAndInitFromRaw(schedSample, deliveryType: .scheduled)
        
        let tempSample: TPDataBasal = createTempBasalItem(0.55)
        checkSerializeAndInitFromRaw(tempSample, deliveryType: .temp)

        let suspendSample: TPDataBasal = createSuspendBasalItem(.scheduled, rate: 0.25)
        checkSerializeAndInitFromRaw(suspendSample, deliveryType: .suspend)

        let expectation = self.expectation(description: "post of basal sample data completed")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin/Dataset...")
        ensureDataset() {
            dataset, session in
            XCTAssert(tpKit.isLoggedIn())
            
            tpKit.putData(samples: [autoSample, schedSample, tempSample, suspendSample], into: dataset) {
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
    
    func test13GetDeviceData_Basal() {
        let expectation = self.expectation(description: "Fetch of basal data complete")
        let tpKit = getTpKitSingleton()
        // first, ensure we are logged in, and then ...
        NSLog("\(#function): next calling ensureLogin...")
        ensureLogin() {
            session in
            XCTAssert(tpKit.isLoggedIn())
            // last hour:
            let end = Date()
            let start = end.addingTimeInterval(-self.kOneHourTimeInterval)
            // around a particular date
            //let dateStr = "2019-01-21T03:28:30.000Z"
            //let itemDate = self.dateFromStr(dateStr)
            //let end =  itemDate.addingTimeInterval(self.kOneDayTimeInterval)
            //let start = itemDate.addingTimeInterval(-self.kOneDayTimeInterval)
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
    
    func test14TestBasalExample() {
        
        let tpKit = getTpKitSingleton()
        let expectation = self.expectation(description: "post of basal example data completed")
        let intialItemTime = self.dateFromStr("2016-10-07T07:00:00.000Z")
        let firstTempTime = self.dateFromStr("2016-10-07T07:25:00.000Z")
        let secondTempTime = self.dateFromStr("2016-10-07T08:00:00.000Z")
        let thirdTempTime = self.dateFromStr("2016-10-07T10:00:00.000Z")

        // first, delete any existing data from previous test run...
        self.deleteTestItems(intialItemTime.addingTimeInterval(-1), end: intialItemTime.addingTimeInterval(kOneDayTimeInterval)) {
            result in
            
            // let's say a user programs a temp basal at 12:25 a.m. to run for three hours, until 3:25 a.m. Then the scheduled basal will look almost the same (as a 24 hours one), except the duration will be different since the scheduled segment will have only run for the twenty-five minutes from midnight to 12:25 a.m.
            let item1: TPDataBasal = TPDataBasalScheduled(time: intialItemTime, rate: 0.25, scheduleName: "Standard", duration: 1500.0) // 25 minutes from 12:00 a.m. to 12:25 a.m.
            item1.clockDriftOffset = 0
            item1.conversionOffset = 0
            item1.deviceId = "DevId0987654321"
            item1.deviceTime = "2016-10-07T00:00:00"
            item1.timeZoneOffset = -420
            
            // The three-hour temp basal will cross schedule boundaries at 1 a.m. and 3 a.m., and so it will end up being divided into three segment intervals with a suppressed to match the segment of the schedule that would have been in effect at that time if the temp had not been programmed.
            // First temp interval:
            let item2: TPDataBasal = TPDataBasalTemporary(time: firstTempTime, duration: 2100.0, expectedDuration: nil, rate: 0.125, percent: 0.5, suppressed: TPDataSuppressed(.scheduled, rate: 0.25, scheduleName: "Standard")) // 35 minutes from 12:25 a.m. to 1:00 a.m.
            item2.clockDriftOffset = 0
            item2.conversionOffset = 0
            item2.deviceId = "DevId0987654321"
            item2.deviceTime = "2016-10-07T00:25:00"
            item2.timeZoneOffset = -420

            // Second temp interval:
             let item3: TPDataBasal = TPDataBasalTemporary(time: secondTempTime, duration: 7200.0, expectedDuration: nil, rate: 0.1, percent: 0.5, suppressed: TPDataSuppressed(.scheduled, rate: 0.2, scheduleName: "Standard")) // 2 hours from 1:00 a.m. to 3:00 a.m.
            item3.clockDriftOffset = 0
            item3.conversionOffset = 0
            item3.deviceId = "DevId0987654321"
            item3.deviceTime = "2016-10-07T01:00:00"
            item3.timeZoneOffset = -420

            // Third temp interval:
            let item4: TPDataBasal = TPDataBasalTemporary(time: thirdTempTime, duration: 1500.0, expectedDuration: nil, rate: 0.125, percent: 0.5, suppressed: TPDataSuppressed(.scheduled, rate: 0.25, scheduleName: "Standard")) // 25 minutes from 3:00 a.m. to 3:25 a.m.
            item4.clockDriftOffset = 0
            item4.conversionOffset = 0
            item4.deviceId = "DevId0987654321"
            item4.deviceTime = "2016-10-07T03:00:00"
            item4.timeZoneOffset = -420

            
             // first, ensure we are logged in, and then ...
            NSLog("\(#function): next calling ensureLogin/Dataset...")
            guard let dataset = testDataset, let _ = tpKit.currentSession else {
                XCTFail("no session and/or dataset!")
                return
            }
            
            tpKit.putData(samples: [item1, item2, item3, item4], into: dataset) {
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

    func test15TestNestedSuppressExample() {
        
        let tpKit = getTpKitSingleton()
        let expectation = self.expectation(description: "post of basal nest suppressed completed")
        let intialItemTime = self.dateFromStr("2016-10-10T06:00:00.000Z")
        
        // first, delete any existing data from previous test run...
        self.deleteTestItems(intialItemTime.addingTimeInterval(-1), end: intialItemTime.addingTimeInterval(1)) {
            result in
            
            // let's say a user programs a temp basal at 12:25 a.m. to run for three hours, until 3:25 a.m. Then the scheduled basal will look almost the same (as a 24 hours one), except the duration will be different since the scheduled segment will have only run for the twenty-five minutes from midnight to 12:25 a.m.
            let item1: TPDataBasal = TPDataBasalSuppressed(time: intialItemTime, duration: 41400.0,  suppressed: TPDataSuppressed(.temp, rate: 0.6, percent: 0.5, scheduleName: nil, suppressed: TPData2ndLevelSuppressed(.scheduled, rate: 1.2, scheduleName: "Very Active")))
            item1.clockDriftOffset = 0
            item1.conversionOffset = 0
            item1.deviceId = "DevId0987654321"
            item1.deviceTime = "2016-10-09T23:00:00"
            item1.timeZoneOffset = -420
            item1.guid = "58812f26-e734-4b9a-9162-02bfee2a1dce"
            
            // first, ensure we are logged in, and then ...
            NSLog("\(#function): next calling ensureLogin/Dataset...")
            guard let dataset = testDataset, let _ = tpKit.currentSession else {
                XCTFail("no session and/or dataset!")
                return
            }
            
            tpKit.putData(samples: [item1], into: dataset) {
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

    func test16Test2017Example() {
        
        let tpKit = getTpKitSingleton()
        let expectation = self.expectation(description: "post of basal test 2017 example completed")
        let intialItemTime = self.dateFromStr("2017-04-22T03:13:27.000Z")
        
        // first, delete any existing data from previous test run...
        self.deleteTestItems(intialItemTime.addingTimeInterval(-1), end: intialItemTime.addingTimeInterval(1)) {
            result in
            
            // let's say a user programs a temp basal at 12:25 a.m. to run for three hours, until 3:25 a.m. Then the scheduled basal will look almost the same (as a 24 hours one), except the duration will be different since the scheduled segment will have only run for the twenty-five minutes from midnight to 12:25 a.m.
            let item1: TPDataBasal = TPDataBasalScheduled(time: intialItemTime, rate: 0.6, scheduleName: "standard", duration: 889.0)
            item1.clockDriftOffset = 0
            item1.conversionOffset = 0
            item1.deviceId = "MedT-723-359329"
            item1.deviceTime = "2017-04-21T20:13:27"
            item1.timeZoneOffset = -420
            item1.guid = "ef242f7d-c40c-4424-9980-7d54d0e609a9"
            var payloadData: [String: Any] = [:]
            let indices: [Int] = [3222]
            payloadData["logIndices"] = indices
            item1.payload = TPDataPayload(payloadData)
            // createdUserId: "b3aaa9d541", modifiedUserId: "b3aaa9d541"
            NSLog("created test 2017 basal item: \(item1)")
            
            // first, ensure we are logged in, and then ...
            NSLog("\(#function): next calling ensureLogin/Dataset...")
            guard let dataset = testDataset, let _ = tpKit.currentSession else {
                XCTFail("no session and/or dataset!")
                return
            }
            
            tpKit.putData(samples: [item1], into: dataset) {
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

}
