//
//  Logging.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 1/17/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import os.log

public class Logging: TLogging {
    public func debug(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        os_log("DEBUG: %{public}@ %@", type: .debug, message, location(function: function, file: file, line: line))
    }

    public func info(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        os_log("INFO: %{public}@ %@", type: .info, message, location(function: function, file: file, line: line))
    }

    public func error(_ message: String, function: StaticString, file: StaticString, line: UInt) {
        os_log("ERROR: %{public}@ %@", type: .error, message, location(function: function, file: file, line: line))
    }

    private func location(function: StaticString, file: StaticString, line: UInt) -> String {
        return "[\(URL(fileURLWithPath: file.description).lastPathComponent):\(line):\(function)]"
    }
}
