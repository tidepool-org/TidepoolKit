//
//  LegacyResponse.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/25/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

struct LegacyResponse {
    struct Success<D>: Codable where D: Codable {
        var data: D
        var meta: Meta?
    }

    struct Failure: Codable {
        var errors: [TError.Detail]
        var meta: Meta?
    }

    struct Meta: Codable {
        var trace: Trace?

        struct Trace: Codable {
            var request: String?
            var session: String?
        }
    }
}
