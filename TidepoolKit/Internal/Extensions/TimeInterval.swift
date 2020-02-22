//
//  TimeInterval.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 11/5/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

extension TimeInterval {
    static let millisecond = milliseconds(1)

    static func milliseconds(_ milliseconds: Double) -> TimeInterval {
        return self.init(milliseconds: milliseconds)
    }

    init(milliseconds: Double) {
        self.init(milliseconds / 1000)
    }

    var milliseconds: Double {
        return self * 1000
    }
}
