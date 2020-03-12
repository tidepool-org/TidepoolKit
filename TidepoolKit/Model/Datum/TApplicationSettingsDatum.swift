//
//  TApplicationSettingsDatum.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 3/7/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation

public class TApplicationSettingsDatum: TDatum, Decodable {
    public var name: String?
    public var version: String?

    public init(time: Date, name: String, version: String) {
        self.name = name
        self.version = version
        super.init(.applicationSettings, time: time)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.version = try container.decodeIfPresent(String.self, forKey: .version)
        try super.init(.applicationSettings, from: decoder)
    }

    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(version, forKey: .version)
        try super.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case version
    }
}
