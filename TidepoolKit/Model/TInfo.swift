//
//  TInfo.swift
//  TidepoolKit
//
//  Created by Rick Pasetto on 9/7/21.
//  Copyright © 2021 Tidepool Project. All rights reserved.
//

public struct TInfo: Codable, Equatable {
    public struct TVersionInfo: Codable, Equatable {
        public struct TLoopVersionInfo: Codable, Equatable {
            public var minimumSupported: String?
            public var criticalUpdateNeeded: [String]?
            public init(minimumSupported: String? = nil, criticalUpdateNeeded: [String]? = nil) {
                self.minimumSupported = minimumSupported
                self.criticalUpdateNeeded = criticalUpdateNeeded
            }
            public func needsCriticalUpdate(version: String) -> Bool {
                return criticalUpdateNeeded?.contains(version) ?? false
            }
            public func needsSupportedUpdate(version: String) -> Bool {
                guard let minimumSupported = minimumSupported,
                      let minimumSupportedVersion = SemanticVersion(minimumSupported),
                      let thisVersion = SemanticVersion(version) else {
                    return false
                }
                return thisVersion < minimumSupportedVersion
            }
        }
        public var loop: TLoopVersionInfo?
        
        public init(loop: TLoopVersionInfo? = nil) {
            self.loop = loop
        }
    }

    public var versions: TVersionInfo
}

struct SemanticVersion: Comparable {
    static let versionRegex = "[0-9]+.[0-9]+.[0-9]+"
    let value: String
    init?(_ value: String) {
        guard value.matches(SemanticVersion.versionRegex) else { return nil }
        self.value = value
    }
    static func < (lhs: SemanticVersion, rhs: SemanticVersion) -> Bool {
        let lhsParts = lhs.value.split(separator: ".")
        let rhsParts = rhs.value.split(separator: ".")
        switch lhsParts[0].compare(rhsParts[0], options: String.CompareOptions.numeric) {
        case .orderedAscending:
            return true
        case .orderedSame:
            switch lhsParts[1].compare(rhsParts[1], options: String.CompareOptions.numeric) {
            case .orderedAscending:
                return true
            case .orderedSame:
                switch lhsParts[2].compare(rhsParts[2], options: String.CompareOptions.numeric) {
                case .orderedAscending:
                    return true
                case .orderedSame:
                    return false
                case .orderedDescending:
                    return false
                }
            case .orderedDescending:
                return false
            }
        case .orderedDescending:
            return false
        }
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
