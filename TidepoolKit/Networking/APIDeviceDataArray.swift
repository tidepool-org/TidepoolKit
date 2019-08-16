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

import Foundation

/// APIDeviceDataArray objects are created for either uploading/deleting, or as a result of a download. This is basically a factory object used to convert between service json data and TPDeviceData objects.
class APIDeviceDataArray: TPFetchable, TPUploadable {
    
    var userData: [TPDeviceData]

    init(_ userData: [TPDeviceData]) {
        self.userData = userData
    }
    
    var debugDescription: String {
        get {
            var result = "TPUserDataArray \(userData.count) items:"
            for item in userData {
                result += "\n" + item.debugDescription
            }
            return result
        }
    }
    
    class func userDataFromJsonData(_ data: Data) -> APIDeviceDataArray? {
        do {
            let object: Any = try JSONSerialization.jsonObject(with: data)
            if let jsonArray = object as? [[String: Any]] {
                var items: [TPDeviceData] = []
                for jsonDict in jsonArray {
                    LogInfo("APIUserDataArray.userDataFromJsonData calling createFromJson on \(jsonDict)")
                    if let item = TPDeviceData.createFromJson(jsonDict) {
                        items.append(item)
                    }
                }
                return APIDeviceDataArray(items)
            } else {
                LogError("Received data not json decodable!")
            }
        } catch (let error) {
            LogError("Received data not json decodable: \(error)")
        }
        return nil
    }
    
    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/data/" + userId
        return urlExtension
    }
    
    static func fromJsonData(_ data: Data) -> TPFetchable? {
        return APIDeviceDataArray.userDataFromJsonData(data)
    }
    
    //
    // MARK: TPUploadable
    //
    
    func postBodyData() -> Data? {
        // TODO: complete!
        let tpDataItems = userData
        guard !tpDataItems.isEmpty else {
            LogError("TPUserDataArray.postBodyData() array is empty!")
            return nil
        }
        var postBodyDictArray: [[String: Any]] = []
        for item in tpDataItems {
            postBodyDictArray.append(item.rawValue)
        }
        guard !postBodyDictArray.isEmpty else {
            LogError("APIUserDataArray.postBodyData() no valid samples!")
            return nil
        }
        guard JSONSerialization.isValidJSONObject(postBodyDictArray) else {
            LogError("APIUserDataArray.postBodyData() invalid json object: \(postBodyDictArray)!")
            return nil
        }
        do {
            let postBody = try JSONSerialization.data(withJSONObject: postBodyDictArray)
            return postBody
        } catch {
            LogError("APIUserDataArray.postBodyData() unable to serialize array \(postBodyDictArray)!")
            return nil
        }
    }
    
    func parseErrResponse(_ response: Data) -> [Int]? {
        var messageParseError = false
        var rejectedSamples: [Int] = []
        
        func parseErrorDict(_ errDict: Any) {
            guard let errDict = errDict as? [String: Any] else {
                NSLog("Error message source field is not valid!")
                messageParseError = true
                return
            }
            guard let errStr = errDict["pointer"] as? String else {
                NSLog("Error message source pointer missing or invalid!")
                messageParseError = true
                return
            }
            print("next error is \(errStr)")
            guard errStr.count >= 2 else {
                NSLog("Error message pointer string too short!")
                messageParseError = true
                return
            }
            let parser = Scanner(string: errStr)
            parser.scanLocation = 1
            var index: Int = -1
            guard parser.scanInt(&index) else {
                NSLog("Unable to find index in error message!")
                messageParseError = true
                return
            }
            print("index of next bad sample is: \(index)")
            rejectedSamples.append(index)
        }
        
        var responseDict: [String: Any] = [:]
        do {
            let json = try JSONSerialization.jsonObject(with: response)
            if let jsonDict = json as? [String: Any] {
                responseDict = jsonDict
            } else {
                LogError("Response message not a dictionary!")
                return nil
            }
        } catch {
            LogError("Unable to parse upload response message as dictionary!")
            return nil
        }
        
        if let errorArray = responseDict["errors"] as? [[String: Any]] {
            for errorDict in errorArray {
                if let source = errorDict["source"] {
                    parseErrorDict(source)
                }
            }
        } else {
            if let source = responseDict["source"] as? [String: Any] {
                parseErrorDict(source)
            }
        }
        
        if !messageParseError && rejectedSamples.count > 0 {
            return rejectedSamples
        } else {
            return nil
        }
    }
    
}

/*
 
 
 // Example of json error response:
 
 {
 "code": "value-out-of-range",
 "title": "value is out of range",
 "detail": "value 1137 is not between 0 and 1000",
 "source": {
 "pointer": "/0/value"
 },
 "meta": {
 "type": "cbg"
 }
 }
 
 
 // Example of json for APIUserDataArray with two samples, one cbg, and one basal...
 
 var jsonUserData = """
 [
 {
 "uploadId" : "0f7394fb80e46fad990b6cb2fa034a24",
 "type" : "cbg",
 "payload" : {
 "Trend Arrow" : "Flat",
 "Transmitter Time" : "2019-04-06T23:55:06.000Z",
 "HKDeviceName" : "10386270000221",
 "Trend Rate" : -0.10000000000000001,
 "HKTimeZone" : "America/Los_Angeles",
 "Status" : "IN_RANGE"
 },
 "units" : "mmol/L",
 "id" : "996afef4050c0fd9271e2d9517bde367",
 "value" : 7.6045199999999999,
 "time" : "2019-04-06T23:55:06.000Z",
 "origin" : {
 "type" : "service",
 "payload" : {
 "sourceRevision" : {
 "operatingSystemVersion" : "12.2.0",
 "source" : {
 "bundleIdentifier" : "com.dexcom.G6",
 "name" : "Dexcom G6"
 },
 "productType" : "iPhone10,6",
 "version" : "15631"
 }
 },
 "id" : "65C55636-BD6F-4D62-9946-007734BE254E",
 "name" : "com.apple.HealthKit"
 }
 },
 {
 "uploadId" : "0f7394fb80e46fad990b6cb2fa034a24",
 "deliveryType" : "temp",
 "payload" : {
 "HKMetadataKeySyncVersion" : 1,
 "HKMetadataKeySyncIdentifier" : "74656d70426173616c20302e35373520323031392d30342d30365432333a35333a33385a203430372e36333235303030353234353231",
 "com.loopkit.InsulinKit.MetadataKeyScheduledBasalRate" : "0.8 IU/hr",
 "HasLoopKitOrigin" : 1,
 "HKInsulinDeliveryReason" : 1
 },
 "type" : "basal",
 "id" : "6f1e00831ba7d761af8d0a70c2979689",
 "duration" : 407632,
 "suppressed" : {
 "deliveryType" : "scheduled",
 "rate" : 0.80000000000000004,
 "type" : "basal"
 },
 "rate" : 1.3247226360275874,
 "time" : "2019-04-06T23:53:38.971Z",
 "origin" : {
 "type" : "service",
 "payload" : {
 "device" : {
 "localIdentifier" : "1F05E6F8",
 "firmwareVersion" : "2.8.0",
 "model" : "Eros",
 "softwareVersion" : "44.0",
 "name" : "Omnipod",
 "manufacturer" : "Insulet"
 },
 "sourceRevision" : {
 "version" : "53",
 "operatingSystemVersion" : "12.2.0",
 "source" : {
 "name" : "Loop",
 "bundleIdentifier" : "com.34SNZ39Q48.loopkit.Loop"
 },
 "productType" : "iPhone10,6"
 }
 },
 "id" : "F47B648B-5856-42B6-AA88-28AF2AA23BA9",
 "name" : "com.apple.HealthKit"
 }
 }]
 """.data(using: .utf8)!
 
 */
