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

// Note: This is meant to specify any optional data types that are commonly expected to be in all TPData types contained in the first level of a TPSampleData object, and that can be uploaded/downloaded together to/from the Tidepool service. These fields would be added after initialization, and validated when set...
public class TPUserData {
    
    public var id: String?
    public var time: Date?
    public var origin: TPDataOrigin?
    public var payload: TPDataPayload?
    public var location: Location? = nil
    public var tags: [String]? = nil     // set of tag (string; 1 <= len <= 100); 1 <= len <= 100; duplicates not allowed; returns ordered alphabetically
    public var notes: [String]? = nil     // array of note (string; 1 <= len <= 1000; NOT the same as messages); optional; 1 <= len <= 100; retains order
    public var associations: [Association]? = nil    // 1 <= len <= 100

    public init?(time: Date) {
        self.id = nil
        self.time = time
        self.origin = nil
        self.payload = nil
    }
    
    var debugDescription: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
    
    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    public init?(rawValue: RawValue) {
        // optionals...
        self.time = DateUtils.dateFromJSON(rawValue["time"] as? String)
        if self.time == nil {
            return nil
        }
        self.id = rawValue["id"] as? String
        self.origin = TPDataType.getTypeFromDict(TPDataOrigin.self, rawValue)
        self.payload = TPDataType.getTypeFromDict(TPDataPayload.self, rawValue)
    }

    public var rawValue: RawValue {
        fatalError()
    }
    
    func baseRawValue(_ tpType: TPDataType) -> RawValue {
        var result = [String: Any]()
        result["type"] = tpType.rawValue as Any?
        result["id"] = self.id
        if let time = time {
            result["time"] = DateUtils.dateToJSON(time) as Any?
        }
        self.origin?.addSelfToDict(&result)
        self.payload?.addSelfToDict(&result)
        return result
    }

    /// Parses json to create a specific TPSampleData subclass item.
    class func createFromJson(_ jsonDict: [String: Any]) -> TPUserData? {
        
        // parse thru dictionary to create tpItem!
        guard let type = jsonDict["type"] as? String else {
            LogError("item has no type field!")
            return nil
        }
        
        // Based on type field, call type-specific init to create the object...
        var tpData: TPUserData? = nil
        guard let tpType = TPDataType(rawValue: type) else {
            LogError("Type \(type) not supported!")
            return nil
        }
        
        switch tpType {
        case .cbg:
            LogInfo("TPDataCommon.createFromJson found cbg item!")
            tpData = TPDataCbg(rawValue: jsonDict)
        case .food:
            LogInfo("TPDataCommon.createFromJson found food item!")
            tpData = TPDataFood(rawValue: jsonDict)
        case .basal:
            // TODO!
            LogInfo("TPDataCommon.createFromJson ignored basal item!")
            //tpData = TPDataBasal.createBasalFromJson(jsonDict, id: id, time: time)
            break
        default:
            LogInfo("TPDataCommon.createFromJson ignored \(type) item!")
            break
        }
        return tpData
    }
    

}

