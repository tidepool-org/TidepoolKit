//
//  TPKitLogging.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/19/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// User of the TPHealthKitUploader framework must configure the framework passing an object with this protocol which the framework will use as documented below.
public protocol TPKitLogging {
    /// logging callbacks...
    func logVerbose(_ msg: String, file: StaticString, function: StaticString, line: UInt)
    func logError(_ msg: String, file: StaticString, function: StaticString, line: UInt)
    func logInfo(_ msg: String, file: StaticString, function: StaticString, line: UInt)
}
