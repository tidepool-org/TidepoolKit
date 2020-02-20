//
//  DNS+TEnvironment.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/17/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

extension Array where Element == DNSSRVRecord {
    var environments: [TEnvironment] { sorted().compactMap { $0.environment } }
}

extension DNSSRVRecord {
    var environment: TEnvironment {
        return TEnvironment(host: host, port: port)
    }
}

extension DNSSRVRecord: Comparable {
    public static func < (lhs: DNSSRVRecord, rhs: DNSSRVRecord) -> Bool {
        if lhs.priority < rhs.priority {
            return true
        } else if lhs.priority > rhs.priority {
            return false
        }
        if lhs.weight > rhs.weight {
            return true
        } else if lhs.weight < rhs.weight {
            return false
        }
        if lhs.host == rhs.host {
            return lhs.port < rhs.port
        } else if lhs.host == "localhost" {
            return false
        } else if rhs.host == "localhost" {
            return true
        } else {
            return lhs.host < rhs.host
        }
    }
}
