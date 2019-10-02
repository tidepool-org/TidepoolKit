//
//  TPDeviceDataArrayExtension.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// TPDeviceDataArray objects are created for either uploading/deleting, or as a result of a download. This is basically a factory object used to convert between service json data and TPDeviceData objects.
extension TPDeviceDataArray: TPFetchable, TPUploadable {
    
    //
    // MARK: - TPFetchable protocol conformance methods
    //
    
    class func urlExtension(forUser userId: String) -> String {
        let urlExtension = "/data/" + userId
        return urlExtension
    }
    
    class func fromJsonData(_ data: Data) -> TPFetchable? {
        guard let jsonDictArray = dictArrayFromJsonData(data) else {
            return nil
        }
        var items: [TPDeviceData] = []
        for jsonDict in jsonDictArray {
            LogInfo("TPDeviceDataArray.userDataFromJsonData calling createFromJson on \(jsonDict)")
            if let item = TPDeviceData.createFromJson(jsonDict) {
                items.append(item)
            }
        }
        return TPDeviceDataArray(items)
    }
    
    //
    // MARK: TPUploadable
    //
    
    func postBodyData() -> Data? {
        return postBodyData(userData)
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
        
        guard let json = try? JSONSerialization.jsonObject(with: response) else {
            LogError("Unable to parse upload response message as json!")
            return nil
        }
        
        guard let responseDict = json as? [String: Any] else {
            LogError("Response json not a dictionary: \(json)")
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
