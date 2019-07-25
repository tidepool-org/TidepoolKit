//
//  TPKitLoggerExample.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/19/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

/// Example logger for getting logging information from TidepoolKit.
public class TPKitLoggerExample: TPLogging {
    
    public init() {
    }

    public func logError(_ msg: String, file: StaticString, function: StaticString, line: UInt) {
        NSLog(String("TPKit-E[\(function):\(line)] \(msg)"))
    }
    
    public func logVerbose(_ msg: String, file: StaticString, function: StaticString, line: UInt) {
        NSLog(String("TPKit-V[\(function):\(line)] \(msg)"))
    }
    
    public func logInfo(_ msg: String, file: StaticString, function: StaticString, line: UInt) {
        NSLog(String("TPKit-I[\(function):\(line)] \(msg)"))
    }
}
