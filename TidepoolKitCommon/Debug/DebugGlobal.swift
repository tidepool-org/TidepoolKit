//
//  DebugGlobal.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/19/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

func LogInfo(_ message: @autoclosure () -> String,  file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    globalLogger?.logInfo(message(), file: file, function: function, line: line)
}

func LogVerbose(_ message: @autoclosure () -> String,  file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    globalLogger?.logVerbose(message(), file: file, function: function, line: line)
}

func LogError(_ message: @autoclosure () -> String,  file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    globalLogger?.logError(message(), file: file, function: function, line: line)
}

