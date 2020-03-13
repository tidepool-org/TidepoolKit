//
//  TDatumTests.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 11/6/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import XCTest
import TidepoolKit

class TDatumTests: XCTestCase {
    static let datum = TDatum(.cbg,
                              time: Date.test,
                              annotations: [TDictionary(["a": "b", "c": 0]), TDictionary(["alpha": "bravo"])],
                              associations: [TAssociationTests.association, TAssociationTests.association],
                              clockDriftOffset: 1234,
                              conversionOffset: 2345,
                              dataSetId: "3456789012",
                              deviceId: "TestDevice",
                              deviceTime: "2019-01-02T03:04:05",
                              id: "2345678901",
                              location: TLocationTests.location,
                              notes: ["One", "Two"],
                              origin: TOriginTests.origin,
                              payload: TDictionary(["foo": "bar"]),
                              tags: ["Fast", "Slow"],
                              timezone: "America/Los_Angeles",
                              timezoneOffset: 25200)
    static let datumJSONDictionary: [String: Any] = [
        "type": "water",
        "time": Date.testJSONString,
        "annotations": [["a": "b", "c": 0], ["alpha": "bravo"]],
        "associations": [TAssociationTests.assocationJSONDictionary, TAssociationTests.assocationJSONDictionary],
        "clockDriftOffset": 1234,
        "conversionOffset": 2345,
        "uploadId": "3456789012",
        "deviceId": "TestDevice",
        "deviceTime": "2019-01-02T03:04:05",
        "id": "2345678901",
        "location": TLocationTests.locationJSONDictionary,
        "notes": ["One", "Two"],
        "origin": TOriginTests.originJSONDictionary,
        "payload": ["foo": "bar"],
        "tags": ["Fast", "Slow"],
        "timezone": "America/Los_Angeles",
        "timezoneOffset": 420
    ]
    
    func testInitializer() {
        let datum = TDatumTests.datum
        XCTAssertEqual(datum.type, .cbg)
        XCTAssertEqual(datum.time, Date.test)
        XCTAssertEqual(datum.annotations, [TDictionary(["a": "b", "c": 0]), TDictionary(["alpha": "bravo"])])
        XCTAssertEqual(datum.associations, [TAssociationTests.association, TAssociationTests.association])
        XCTAssertEqual(datum.clockDriftOffset, 1234)
        XCTAssertEqual(datum.conversionOffset, 2345)
        XCTAssertEqual(datum.dataSetId, "3456789012")
        XCTAssertEqual(datum.deviceId, "TestDevice")
        XCTAssertEqual(datum.deviceTime, "2019-01-02T03:04:05")
        XCTAssertEqual(datum.id, "2345678901")
        XCTAssertEqual(datum.location, TLocationTests.location)
        XCTAssertEqual(datum.notes, ["One", "Two"])
        XCTAssertEqual(datum.origin, TOriginTests.origin)
        XCTAssertEqual(datum.payload, TDictionary(["foo": "bar"]))
        XCTAssertEqual(datum.tags, ["Fast", "Slow"])
        XCTAssertEqual(datum.timezone, "America/Los_Angeles")
        XCTAssertEqual(datum.timezoneOffset, 25200)
    }
}

class TDatumDatumTypeTests: XCTestCase {
    func testDatumType() {
        XCTAssertEqual(TDatum.DatumType.basal.rawValue, "basal")
        XCTAssertEqual(TDatum.DatumType.bloodKetone.rawValue, "bloodKetone")
        XCTAssertEqual(TDatum.DatumType.bolus.rawValue, "bolus")
        XCTAssertEqual(TDatum.DatumType.calculator.rawValue, "wizard")
        XCTAssertEqual(TDatum.DatumType.cbg.rawValue, "cbg")
        XCTAssertEqual(TDatum.DatumType.cgmSettings.rawValue, "cgmSettings")
        XCTAssertEqual(TDatum.DatumType.deviceEvent.rawValue, "deviceEvent")
        XCTAssertEqual(TDatum.DatumType.food.rawValue, "food")
        XCTAssertEqual(TDatum.DatumType.insulin.rawValue, "insulin")
        XCTAssertEqual(TDatum.DatumType.physicalActivity.rawValue, "physicalActivity")
        XCTAssertEqual(TDatum.DatumType.pumpSettings.rawValue, "pumpSettings")
        XCTAssertEqual(TDatum.DatumType.reportedState.rawValue, "reportedState")
        XCTAssertEqual(TDatum.DatumType.smbg.rawValue, "smbg")
        XCTAssertEqual(TDatum.DatumType.upload.rawValue, "upload")
        XCTAssertEqual(TDatum.DatumType.water.rawValue, "water")
    }
}

class TDatumFilterTests: XCTestCase {
    static let filter = TDatum.Filter(startDate: Date.test,
                                      endDate: Date.test,
                                      dataSetId: "1234567890",
                                      deviceId: "2345678901",
                                      carelink: true,
                                      dexcom: false,
                                      medtronic: true,
                                      latest: false,
                                      types: ["cgm", "bolus"],
                                      subTypes: ["normal", "extended"])

    func testInitializer() {
        let filter = TDatumFilterTests.filter
        XCTAssertEqual(filter.startDate, Date.test)
        XCTAssertEqual(filter.endDate, Date.test)
        XCTAssertEqual(filter.dataSetId, "1234567890")
        XCTAssertEqual(filter.deviceId, "2345678901")
        XCTAssertEqual(filter.carelink, true)
        XCTAssertEqual(filter.dexcom, false)
        XCTAssertEqual(filter.medtronic, true)
        XCTAssertEqual(filter.latest, false)
        XCTAssertEqual(filter.types, ["cgm", "bolus"])
        XCTAssertEqual(filter.subTypes, ["normal", "extended"])
    }

    func testQueryItems() {
        XCTAssertEqual(TDatumFilterTests.filter.queryItems, [URLQueryItem(name: "startDate", value: Date.testJSONString),
                                                             URLQueryItem(name: "endDate", value: Date.testJSONString),
                                                             URLQueryItem(name: "uploadId", value: "1234567890"),
                                                             URLQueryItem(name: "deviceId", value: "2345678901"),
                                                             URLQueryItem(name: "carelink", value: "true"),
                                                             URLQueryItem(name: "dexcom", value: "false"),
                                                             URLQueryItem(name: "medtronic", value: "true"),
                                                             URLQueryItem(name: "latest", value: "false"),
                                                             URLQueryItem(name: "types", value: "cgm,bolus"),
                                                             URLQueryItem(name: "subTypes", value: "normal,extended")])
    }
}

extension TDatum: Equatable {

    // NOTE: Yes, a bit of a hack, but it is explicitly only used for tests.
    public static func == (lhs: TDatum, rhs: TDatum) -> Bool {
        switch (lhs, rhs) {
        case let (lhs as TCBGDatum, rhs as TCBGDatum):
            return lhs.isEqual(to: rhs)
        case let (lhs as TFoodDatum, rhs as TFoodDatum):
            return lhs.isEqual(to: rhs)
        default:
            return false
        }
    }
    
    func isEqual(to other: TDatum) -> Bool {
        return self.type == other.type &&
            self.time == other.time &&
            self.annotations == other.annotations &&
            self.associations == other.associations &&
            self.clockDriftOffset == other.clockDriftOffset &&
            self.conversionOffset == other.conversionOffset &&
            self.dataSetId == other.dataSetId &&
            self.deviceId == other.deviceId &&
            self.deviceTime == other.deviceTime &&
            self.id == other.id &&
            self.location == other.location &&
            self.notes == other.notes &&
            self.origin == other.origin &&
            self.payload == other.payload &&
            self.tags == other.tags &&
            self.timezone == other.timezone &&
            self.timezoneOffset == other.timezoneOffset
    }
}