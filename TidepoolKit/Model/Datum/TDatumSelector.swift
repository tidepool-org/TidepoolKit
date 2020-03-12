//
//  TDatumSelector.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

public struct TDatumSelector: Codable, Equatable {
    public var id: String?
    public var origin: Origin?

    public init(id: String? = nil, origin: Origin? = nil) {
        self.id = id
        self.origin = origin
    }

    public struct Origin: Codable, Equatable {
        public var id: String?

        public init(id: String) {
            self.id = id
        }
    }
}
