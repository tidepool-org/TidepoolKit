//
//  TStatusDeviceEventDatum.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 11/1/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TStatusDeviceEventDatum: TDeviceEventDatum, Decodable {
    public enum Name: String, Codable {
        case resumed
        case suspended
    }

    public var name: Name?
    public var duration: Int?
    public var expectedDuration: Int?
    public var reason: TDictionary?

    public init(time: Date, name: Name? = nil, duration: Int? = nil, expectedDuration: Int? = nil, reason: TDictionary? = nil) {
        self.name = name
        self.duration = duration
        self.expectedDuration = expectedDuration
        self.reason = reason
        super.init(.status, time: time)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(Name.self, forKey: .name)
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        self.expectedDuration = try container.decodeIfPresent(Int.self, forKey: .expectedDuration)
        self.reason = try container.decodeIfPresent(TDictionary.self, forKey: .reason)
        try super.init(.status, from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(expectedDuration, forKey: .expectedDuration)
        try container.encodeIfPresent(reason, forKey: .reason)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case name = "status"
        case duration
        case expectedDuration
        case reason
    }
}
