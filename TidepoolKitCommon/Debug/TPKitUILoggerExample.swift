//
//  TPKitUILoggerExample.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/19/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

/// Example logger for getting logging information from TidepoolKitUI.
public class TPKitUILoggerExample: TPLogging {
    
    public init() {
    }

    public func logError(_ msg: String, file: StaticString, function: StaticString, line: UInt) {
        NSLog(String("TPKitUI-E[\(file):\(line)] \(msg)"))
    }
    
    public func logVerbose(_ msg: String, file: StaticString, function: StaticString, line: UInt) {
        NSLog(String("TPKitUI-V[\(file):\(line)] \(msg)"))
    }
    
    public func logInfo(_ msg: String, file: StaticString, function: StaticString, line: UInt) {
        NSLog(String("TPKitUI-I[\(file):\(line)] \(msg)"))
    }
}
