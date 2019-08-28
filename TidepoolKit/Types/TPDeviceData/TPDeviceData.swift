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
    
    public var id: String?
    public var time: Date?
    public var origin: TPDataOrigin?
    public var payload: TPDataPayload?
    public var location: TPDataLocation?
    // TODO!
    public var tags: [String]? = nil     // set of tag (string; 1 <= len <= 100); 1 <= len <= 100; duplicates not allowed; returns ordered alphabetically
    public var notes: [String]? = nil     // array of note (string; 1 <= len <= 1000; NOT the same as messages); optional; 1 <= len <= 100; retains order
    public var associations: [TPDataAssociation]?   // 1 <= len <= 100

    public init?(time: Date? = nil) {
        self.id = nil
        self.time = time
        self.origin = nil
        self.payload = nil
        self.associations = nil
        self.location = nil
    }
    
    public var description: String {
        get {
            return TPDataType.description(self.rawValue)
        }
    }
    
    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    required public init?(rawValue: RawValue) {
        // optionals...
        self.time = DateUtils.dateFromJSON(rawValue["time"] as? String)
        if self.time == nil {
            return nil
        }
        self.id = rawValue["id"] as? String
        self.origin = TPDataOrigin.getSelfFromDict(rawValue)
        self.payload = TPDataPayload.getSelfFromDict(rawValue)
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
        self.location = TPDataLocation.getSelfFromDict(rawValue)
    }

    public var rawValue: RawValue {
        fatalError()
    }
    
    func baseRawValue(_ tpType: TPDataType) -> RawValue {
        var dict = [String: Any]()
        dict["type"] = tpType.rawValue
        dict["id"] = self.id
        if let time = time {
            dict["time"] = DateUtils.dateToJSON(time)
        }
        self.origin?.addSelfToDict(&dict)
        self.payload?.addSelfToDict(&dict)
        if let associations = self.associations {
            var assocArrayRaw: [[String: Any]] = []
            for item in associations {
                assocArrayRaw.append(item.rawValue)
            }
            dict["associations"] = assocArrayRaw
        }
        self.location?.addSelfToDict(&dict)
        return dict
    }

    /// Parses json to create a specific TPSampleData subclass item.
    class func createFromJson(_ jsonDict: [String: Any]) -> TPDeviceData? {
        
        // parse thru dictionary to create tpItem!
        guard let type = jsonDict["type"] as? String else {
            LogError("item has no type field!")
            return nil
        }
        
        // Based on type field, call type-specific init to create the object...
        var tpData: TPDeviceData? = nil
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

