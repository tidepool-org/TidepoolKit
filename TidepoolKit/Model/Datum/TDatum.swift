//
//  TDatum.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TDatum: Encodable {
    public enum DatumType: String, Codable {
        case basal
        case bloodKetone
        case bolus
        case calculator = "wizard"
        case cbg
        case cgmSettings
        case deviceEvent
        case food
        case insulin
        case physicalActivity
        case pumpSettings
        case reportedState
        case smbg
        case upload // DEPRECATED: Presence here allows decoding to ignore without failing
        case water
    }

    public let type: DatumType
    public var time: Date

    public var annotations: [TDictionary]?
    public var associations: [TAssociation]?
    public var clockDriftOffset: Int?
    public var conversionOffset: Int?
    public var dataSetId: String?
    public var deviceId: String?
    public var deviceTime: String?
    public var id: String?
    public var location: TLocation?
    public var notes: [String]?
    public var origin: TOrigin?
    public var payload: TDictionary?
    public var tags: [String]?
    public var timezone: String?
    public var timezoneOffset: Int?

    public init(_ type: DatumType,
                time: Date,
                annotations: [TDictionary]? = nil,
                associations: [TAssociation]? = nil,
                clockDriftOffset: Int? = nil,
                conversionOffset: Int? = nil,
                dataSetId: String? = nil,
                deviceId: String? = nil,
                deviceTime: String? = nil,
                id: String? = nil,
                location: TLocation? = nil,
                notes: [String]? = nil,
                origin: TOrigin? = nil,
                payload: TDictionary? = nil,
                tags: [String]? = nil,
                timezone: String? = nil,
                timezoneOffset: Int? = nil) {
        self.type = type
        self.time = time
        self.annotations = annotations
        self.associations = associations
        self.clockDriftOffset = clockDriftOffset
        self.conversionOffset = conversionOffset
        self.dataSetId = dataSetId
        self.deviceId = deviceId
        self.deviceTime = deviceTime
        self.id = id
        self.location = location
        self.notes = notes
        self.origin = origin
        self.payload = payload
        self.tags = tags
        self.timezone = timezone
        self.timezoneOffset = timezoneOffset
    }

    init(_ expectedType: DatumType, from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(DatumType.self, forKey: .type)
        guard self.type == expectedType else {
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unexpected type '\(self.type)'")
        }
        self.time = try container.decode(Date.self, forKey: .time)
        self.annotations = try container.decodeIfPresent([TDictionary].self, forKey: .annotations)
        self.associations = try container.decodeIfPresent([TAssociation].self, forKey: .associations)
        self.clockDriftOffset = try container.decodeIfPresent(Int.self, forKey: .clockDriftOffset)
        self.conversionOffset = try container.decodeIfPresent(Int.self, forKey: .conversionOffset)
        self.dataSetId = try container.decodeIfPresent(String.self, forKey: .dataSetId)
        self.deviceId = try container.decodeIfPresent(String.self, forKey: .deviceId)
        self.deviceTime = try container.decodeIfPresent(String.self, forKey: .deviceTime)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.location = try container.decodeIfPresent(TLocation.self, forKey: .location)
        self.notes = try container.decodeIfPresent([String].self, forKey: .notes)
        self.origin = try container.decodeIfPresent(TOrigin.self, forKey: .origin)
        self.payload = try container.decodeIfPresent(TDictionary.self, forKey: .payload)
        self.tags = try container.decodeIfPresent([String].self, forKey: .tags)
        self.timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        self.timezoneOffset = try container.decodeIfPresent(Int.self, forKey: .timezoneOffset)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(time, forKey: .time)
        try container.encodeIfPresent(annotations, forKey: .annotations)
        try container.encodeIfPresent(associations, forKey: .associations)
        try container.encodeIfPresent(clockDriftOffset, forKey: .clockDriftOffset)
        try container.encodeIfPresent(conversionOffset, forKey: .conversionOffset)
        try container.encodeIfPresent(dataSetId, forKey: .dataSetId)
        try container.encodeIfPresent(deviceId, forKey: .deviceId)
        try container.encodeIfPresent(deviceTime, forKey: .deviceTime)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encodeIfPresent(origin, forKey: .origin)
        try container.encodeIfPresent(payload, forKey: .payload)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(timezone, forKey: .timezone)
        try container.encodeIfPresent(timezoneOffset, forKey: .timezoneOffset)
    }

    private enum CodingKeys: String, CodingKey {
        case type
        case time
        case annotations
        case associations
        case clockDriftOffset
        case conversionOffset
        case dataSetId = "uploadId"
        case deviceId
        case deviceTime
        case id
        case location
        case notes
        case origin
        case payload
        case tags
        case timezone
        case timezoneOffset
    }
}

extension TDatum {
    public struct Filter {
        public var startDate: Date?
        public var endDate: Date?
        public var dataSetId: String?
        public var deviceId: String?
        public var carelink: Bool?
        public var dexcom: Bool?
        public var medtronic: Bool?
        public var latest: Bool?
        public var types: [String]?
        public var subTypes: [String]?

        public init(startDate: Date? = nil, endDate: Date? = nil, dataSetId: String? = nil, deviceId: String? = nil,
                    carelink: Bool? = nil, dexcom: Bool? = nil, medtronic: Bool? = nil, latest: Bool? = nil,
                    types: [String]? = nil, subTypes: [String]? = nil) {
            self.startDate = startDate
            self.endDate = endDate
            self.dataSetId = dataSetId
            self.deviceId = deviceId
            self.carelink = carelink
            self.dexcom = dexcom
            self.medtronic = medtronic
            self.latest = latest
            self.types = types
            self.subTypes = subTypes
        }

        public var queryItems: [URLQueryItem]? {
            var queryItems: [URLQueryItem] = []
            if let startDate = startDate {
                queryItems.append(URLQueryItem(name: "startDate", value: startDate.timeString))
            }
            if let endDate = endDate {
                queryItems.append(URLQueryItem(name: "endDate", value: endDate.timeString))
            }
            if let dataSetId = dataSetId {
                queryItems.append(URLQueryItem(name: "uploadId", value: dataSetId))
            }
            if let deviceId = deviceId {
                queryItems.append(URLQueryItem(name: "deviceId", value: deviceId))
            }
            if let carelink = carelink {
                queryItems.append(URLQueryItem(name: "carelink", value: carelink.description))
            }
            if let dexcom = dexcom {
                queryItems.append(URLQueryItem(name: "dexcom", value: dexcom.description))
            }
            if let medtronic = medtronic {
                queryItems.append(URLQueryItem(name: "medtronic", value: medtronic.description))
            }
            if let latest = latest {
                queryItems.append(URLQueryItem(name: "latest", value: latest.description))
            }
            if let types = types {
                queryItems.append(URLQueryItem(name: "types", value: types.joined(separator: ",")))
            }
            if let subTypes = subTypes {
                queryItems.append(URLQueryItem(name: "subTypes", value: subTypes.joined(separator: ",")))
            }
            return queryItems
        }
    }
}