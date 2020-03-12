//
//  TExtendedBolusDatum.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/30/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TExtendedBolusDatum: TBolusDatum, Decodable {
    public var extended: Double?
    public var expectedExtended: Double?
    public var duration: Int?
    public var expectedDuration: Int?

    public init(time: Date, extended: Double, expectedExtended: Double? = nil, duration: Int, expectedDuration: Int? = nil) {
        self.extended = extended
        self.expectedExtended = expectedExtended
        self.duration = duration
        self.expectedDuration = expectedDuration
        super.init(.extended, time: time)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.extended = try container.decodeIfPresent(Double.self, forKey: .extended)
        self.expectedExtended = try container.decodeIfPresent(Double.self, forKey: .expectedExtended)
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        self.expectedDuration = try container.decodeIfPresent(Int.self, forKey: .expectedDuration)
        try super.init(.extended, from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(extended, forKey: .extended)
        try container.encodeIfPresent(expectedExtended, forKey: .expectedExtended)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(expectedDuration, forKey: .expectedDuration)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case extended
        case expectedExtended
        case duration
        case expectedDuration
    }
}
