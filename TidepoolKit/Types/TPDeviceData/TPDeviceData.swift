///
//  TPUserData.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

// Note: This is meant to specify any optional data types that are commonly expected to be in all TPData types contained in the first level of a TPSampleData object, and that can be uploaded/downloaded together to/from the Tidepool service. These fields would be added after initialization, and validated when set...
public class TPDeviceData: RawRepresentable, CustomStringConvertible {
    public let type: TPDataType
    public var time: Date?

    public var associations: [TPDataAssociation]?
    public var clockDriftOffset: Int?     // milliseconds (ToDo: convert to/from TimeInterval?)
    public var conversionOffset: Int?
    public var deviceId: String?
    public var deviceTime: String?        // ToDo: convert to/from Date?
    public var guid: String?
    public var id: String?
    public var location: TPDataLocation?
    public var origin: TPDataOrigin?
    public var payload: TPDataPayload?
    public var notes: [String]? = nil     // ToDo: array of note (string; 1 <= len <= 1000; NOT the same as messages); optional; 1 <= len <= 100; retains order
    public var tags: [String]? = nil      // ToDo: set of tag (string; 1 <= len <= 100); 1 <= len <= 100; duplicates not allowed; returns ordered alphabetically
    public var timeZone: String?          // ToDo: convert to/from TimeZone?
    public var timeZoneOffset: Int?       // minutes (ToDo: convert to/from TimeInterval?)

    public init(_ type: TPDataType, time: Date? = nil) {
        self.type = type
        self.time = time
        self.associations = nil
        self.clockDriftOffset = nil
        self.conversionOffset = nil
        self.deviceId = nil
        self.deviceTime = nil
        self.guid = nil
        self.id = nil
        self.location = nil
        self.origin = nil
        self.payload = nil
        self.timeZone = nil
        self.timeZoneOffset = nil
    }
    
    public var description: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
    
    // MARK: - RawRepresentable

    public typealias RawValue = [String: Any]

    required public init?(rawValue: RawValue) {
        guard let type = TPDeviceData.typeFromJson(rawValue) else {
            return nil
        }
        self.type = type
        self.time = DateUtils.dateFromJSON(rawValue["time"] as? String)
        if self.time == nil {
            return nil
        }
        if let associations = rawValue["associations"] as? [[String: Any]] {
            var assocArray: [TPDataAssociation] = []
            for item in associations {
                if let association = TPDataAssociation(rawValue: item) {
                    assocArray.append(association)
                }
            }
            if !assocArray.isEmpty {
                self.associations = assocArray
            }
        }
        self.clockDriftOffset = rawValue["clockDriftOffset"] as? Int
        self.conversionOffset = rawValue["conversionOffset"] as? Int
        self.deviceId = rawValue["deviceId"] as? String
        self.deviceTime = rawValue["deviceTime"] as? String
        self.guid = rawValue["guid"] as? String
        self.id = rawValue["id"] as? String
        self.location = TPDataLocation.getSelfFromDict(rawValue)
        self.origin = TPDataOrigin.getSelfFromDict(rawValue)
        self.payload = TPDataPayload.getSelfFromDict(rawValue)
        self.timeZone = rawValue["timezone"] as? String
        self.timeZoneOffset = rawValue["timezoneOffset"] as? Int
    }

    public var rawValue: RawValue {
        var rawValue = [String: Any]()
        rawValue["type"] = type.rawValue
         if let time = time {
            rawValue["time"] = DateUtils.dateToJSON(time)
        }
        if let associations = self.associations {
            var assocArrayRaw: [[String: Any]] = []
            for item in associations {
                assocArrayRaw.append(item.rawValue)
            }
            rawValue["associations"] = assocArrayRaw
        }
        rawValue["clockDriftOffset"] = self.clockDriftOffset
        rawValue["conversionOffset"] = self.conversionOffset
        rawValue["deviceId"] = self.deviceId
        rawValue["deviceTime"] = self.deviceTime
        rawValue["guid"] = self.guid
        rawValue["id"] = self.id
        self.location?.addSelfToDict(&rawValue)
        self.origin?.addSelfToDict(&rawValue)
        self.payload?.addSelfToDict(&rawValue)
        rawValue["timezone"] = self.timeZone
        rawValue["timezoneOffset"] = self.timeZoneOffset
        return rawValue
    }

    class func typeFromJson(_ jsonDict: [String: Any]) -> TPDataType? {
        guard let type = jsonDict["type"] as? String else {
            LogError("item has no type field!")
            return nil
        }
        guard let tpType = TPDataType(rawValue: type) else {
            LogError("Type \(type) not supported!")
            return nil
        }
        return tpType
    }
    
    /// Parses json to create a specific TPDeviceData subclass item.
    class func createFromJson(_ jsonDict: [String: Any]) -> TPDeviceData? {
        guard let tpType = typeFromJson(jsonDict) else {
            return nil
        }
        // Based on type field, call type-specific init to create the object...
        var tpData: TPDeviceData? = nil
        switch tpType {
        case .cbg:
            LogInfo("TPDataCommon.createFromJson found cbg item!")
            tpData = TPDataCbg(rawValue: jsonDict)
        case .food:
            LogInfo("TPDataCommon.createFromJson found food item!")
            tpData = TPDataFood(rawValue: jsonDict)
        case .basal:
            LogInfo("TPDataCommon.createFromJson ignored basal item!")
            tpData = TPDataBasal.createBasalFromJson(jsonDict)
            break
        case .bolus:
            LogInfo("TPDataCommon.createFromJson found bolus item!")
            tpData = TPDataBolus.createBolusFromJson(jsonDict)
        default:
            LogInfo("TPDataCommon.createFromJson ignored \(tpType.rawValue) item!")
            break
        }
        return tpData
    }
    
}

/// Class used internally for fetching/uploading device data...
class TPDeviceDataArray {
    
    var userData: [TPDeviceData]

    init(_ userData: [TPDeviceData]) {
        self.userData = userData
    }
}
