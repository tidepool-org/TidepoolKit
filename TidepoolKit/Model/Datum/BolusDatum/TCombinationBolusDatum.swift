//
//  TCombinationBolusDatum.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/30/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TCombinationBolusDatum: TBolusDatum, Decodable {
    public var normal: Double?
    public var expectedNormal: Double?
    public var extended: Double?
    public var expectedExtended: Double?
    public var duration: Int?
    public var expectedDuration: Int?

    public init(time: Date, normal: Double, expectedNormal: Double? = nil, extended: Double, expectedExtended: Double? = nil, duration: Int, expectedDuration: Int? = nil) {
        self.normal = normal
        self.expectedNormal = expectedNormal
        self.extended = extended
        self.expectedExtended = expectedExtended
        self.duration = duration
        self.expectedDuration = expectedDuration
        super.init(.combination, time: time)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.normal = try container.decodeIfPresent(Double.self, forKey: .normal)
        self.expectedNormal = try container.decodeIfPresent(Double.self, forKey: .expectedNormal)
        self.extended = try container.decodeIfPresent(Double.self, forKey: .extended)
        self.expectedExtended = try container.decodeIfPresent(Double.self, forKey: .expectedExtended)
        self.duration = try container.decodeIfPresent(Int.self, forKey: .duration)
        self.expectedDuration = try container.decodeIfPresent(Int.self, forKey: .expectedDuration)
        try super.init(.combination, from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(normal, forKey: .normal)
        try container.encodeIfPresent(expectedNormal, forKey: .expectedNormal)
        try container.encodeIfPresent(extended, forKey: .extended)
        try container.encodeIfPresent(expectedExtended, forKey: .expectedExtended)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(expectedDuration, forKey: .expectedDuration)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case normal
        case expectedNormal
        case extended
        case expectedExtended
        case duration
        case expectedDuration
    }
}
