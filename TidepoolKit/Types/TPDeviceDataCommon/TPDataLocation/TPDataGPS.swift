//
//  TPDataGPS.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/28/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public struct TPDataGPS: TPData {
    public static var tpType: TPDataType { return .gps }

    public let latitude: TPDataLatitude?
    public let longitude: TPDataLongitude?
    public let elevation: TPDataElevation?
    public let floor: Int?
    public let horizontalAccuracy: TPDataHorizontalAccuracy?
    public let verticalAccuracy: TPDataVerticalAccuracy?
    public var origin: TPDataOrigin?
    
    public init(latitude: TPDataLatitude? = nil, longitude: TPDataLongitude? = nil, elevation: TPDataElevation? = nil, floor: Int? = nil, horizontalAccuracy: TPDataHorizontalAccuracy? = nil, verticalAccuracy: TPDataVerticalAccuracy? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.floor = floor
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.origin = nil
    }
    
    // MARK: - RawRepresentable
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        self.latitude = TPDataLatitude.getSelfFromDict(rawValue)
        self.longitude = TPDataLongitude.getSelfFromDict(rawValue)
        self.elevation = TPDataElevation.getSelfFromDict(rawValue)
        self.floor = rawValue["floor"] as? Int
        self.horizontalAccuracy = TPDataHorizontalAccuracy.getSelfFromDict(rawValue)
        self.verticalAccuracy = TPDataVerticalAccuracy.getSelfFromDict(rawValue)
        
        guard !self.rawValue.isEmpty else {
            return nil
        }
    }
    
    public var rawValue: RawValue {
        var rawValue: [String: Any] = [:]
        latitude?.addSelfToDict(&rawValue)
        longitude?.addSelfToDict(&rawValue)
        elevation?.addSelfToDict(&rawValue)
        rawValue["floor"] = floor
        horizontalAccuracy?.addSelfToDict(&rawValue)
        verticalAccuracy?.addSelfToDict(&rawValue)
        origin?.addSelfToDict(&rawValue)
        return rawValue
    }

}
