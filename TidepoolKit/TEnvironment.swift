//
//  TEnvironment.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 1/19/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

/// Representation of a Tidepool API environment that includes a host and port. Typically discovered dynamically
/// via DNS SRV record lookup.
///
/// Network requests will use HTTPS only if port is 443. Otherwise, HTTP will be used.
public struct TEnvironment {

    /// The host for the environment. For example, api.tidepool.org.
    public let host: String

    // The port for the environment. For example, 443.
    public let port: UInt16
    
    public init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }

    public func url(path: String = "", queryItems: [URLQueryItem]? = nil) -> URL {
        var components = URLComponents()
        components.host = host
        switch port {
            case 80:
                components.scheme = "http"
            case 443:
                components.scheme = "https"
            default:
                components.scheme = "http"
                components.port = Int(port)
        }
        components.path = path
        components.queryItems = queryItems
        return components.url!
    }
}

extension TEnvironment: RawRepresentable {
    public typealias RawValue = [String: Any]
    
    public init?(rawValue: RawValue) {
        guard let host = rawValue["host"] as? String,
            let port = rawValue["port"] as? UInt16 else
        {
            return nil
        }
        self.host = host
        self.port = port
    }
    
    public var rawValue: RawValue {
        return [
            "host": host,
            "port": port
        ]
    }
}

extension TEnvironment: CustomStringConvertible {
    public var description: String { "\(host):\(port)" }
}
