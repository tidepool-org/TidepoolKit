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

public enum TPUserDataType: String, Codable {
    case cbg = "cbg"
    case food = "food"
    case basal = "basal"
    case unsupported = "unsupported"
}

public class TPData: RawRepresentable {
    
    public let id: String?
    public let time: Date?
    
    // other optional data...
    public var origin: TPUserDataOrigin?
    public var payload: [String: Any]?

    public init(id: String? = nil , time: Date?) {
        self.id = id
        self.time = time
    }
    
    var debugDescription: String {
        get {
            var result = "\n id: \(id ?? "nil")"
            if let time = time {
                result += "\n time: \(time)"
            }
            if let origin = origin {
                result += "\n\(origin.debugDescription)"
            }
            if let payload = payload {
                result += "\npayload: \(payload)"
            }
            return result
        }
    }
    
    //
    // MARK: - Framework private variables, methods
    //

    // Override!
    public var type: TPUserDataType = .unsupported

    //
    // MARK: - RawRepresentable
    //
    
    public typealias RawValue = [String: Any]
    
    required public init?(rawValue: RawValue) {
        self.id = rawValue["id"] as? String
        self.time = rawValue["time"] as? Date
        if let originDict = rawValue["origin"] as? [String: Any] {
            if let origin = TPUserDataOrigin(rawValue: originDict) {
                self.origin = origin
            }
        }
        if let payload = rawValue["payload"] as? [String: Any] {
            self.payload = payload
        }
    }
    
    public var rawValue: RawValue {
        var result = [String: Any]()
        result["type"] = type.rawValue as Any?
        if let time = time {
            result["time"] = DateUtils.dateToJSON(time) as Any?
        }
        
        // add optional origin if it exists
        if let origin = origin {
            let originDict = origin.rawValue
            if !originDict.isEmpty {
                result["origin"] = origin.rawValue
            }
        }
        
        // add optional payload if it exists
        if let payload = payload {
            if !payload.isEmpty {
                result["payload"] = payload
            }
         }
        
        return result
    }

    //
    // MARK: - Class method to create correct objects...
    //

    /// Parses json to create a specific APIUserDataCommon subclass, which will contain a valid corresponding TPUserDataCommon subclass item.
    class func createFromJson(_ jsonDict: [String: Any]) -> TPData? {
        
        // parse thru dictionary to create tpItem!
        guard let type = jsonDict["type"] as? String else {
            LogError("item has no type field!")
            return nil
        }
        
        // Based on type field, call type-specific init to create the object...
        var tpData: TPData? = nil
        guard let tpType = TPUserDataType(rawValue: type) else {
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

    func addPayload(_ payload: [String: Any]?, serializationDict: inout [String: Any]) {
        
        guard var payload = payload else {
            LogInfo("TPData.addPayload - no payload data!")
            return
        }
        
        for (key, value) in payload {
            // TODO: document this time format adjust!
            if let dateValue = value as? Date {
                payload[key] = DateUtils.dateToJSON(dateValue)
            }
        }
        
        if JSONSerialization.isValidJSONObject(payload) {
            // Add metadata values as the payload struct
            serializationDict["payload"] = payload
        } else {
            LogError("Invalid payload failed to serialize: \(String(describing: payload))")
        }
        
    }

}
