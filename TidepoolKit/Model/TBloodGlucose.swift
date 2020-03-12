//
//  TBloodGlucose.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 11/1/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

public struct TBloodGlucose {
    public enum Units: String, Codable {
        case milligramsPerDeciliter = "mg/dL"
        case millimolesPerLiter = "mmol/L"
    }

    public struct Target: Codable, Equatable {
        public var target: Double?
        public var range: Double?
        public var low: Double?
        public var high: Double?

        public init(target: Double) {
            self.target = target
        }

        public init(target: Double, range: Double) {
            self.target = target
            self.range = range
        }

        public init(target: Double, high: Double) {
            self.target = target
            self.high = high
        }

        public init(low: Double, high: Double) {
            self.low = low
            self.high = high
        }
    }

    public struct StartTarget: Codable, Equatable {
        public var start: Int?
        public var target: Double?
        public var range: Double?
        public var low: Double?
        public var high: Double?

        public init(start: Int, target: Double) {
            self.start = start
            self.target = target
        }

        public init(start: Int, target: Double, range: Double) {
            self.start = start
            self.target = target
            self.range = range
        }

        public init(start: Int, target: Double, high: Double) {
            self.start = start
            self.target = target
            self.high = high
        }

        public init(start: Int, low: Double, high: Double) {
            self.start = start
            self.low = low
            self.high = high
        }
    }
}
