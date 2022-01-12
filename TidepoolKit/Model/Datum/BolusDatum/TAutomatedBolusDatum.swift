//
//  TAutomatedBolusDatum.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 1/7/22.
//  Copyright © 2022 Tidepool Project. All rights reserved.
//

import Foundation

public class TAutomatedBolusDatum: TBolusDatum, Decodable {
    public var normal: Double?
    public var expectedNormal: Double?

    public init(time: Date, normal: Double, expectedNormal: Double? = nil, insulinFormulation: InsulinFormulation? = nil) {
        self.normal = normal
        self.expectedNormal = expectedNormal
        super.init(.automated, time: time, insulinFormulation: insulinFormulation)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.normal = try container.decodeIfPresent(Double.self, forKey: .normal)
        self.expectedNormal = try container.decodeIfPresent(Double.self, forKey: .expectedNormal)
        try super.init(.automated, from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(normal, forKey: .normal)
        try container.encodeIfPresent(expectedNormal, forKey: .expectedNormal)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case normal
        case expectedNormal
    }
}
