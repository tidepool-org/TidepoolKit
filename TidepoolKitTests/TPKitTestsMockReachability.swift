//
//  TPKitTestsMockReachability.swift
//  TidepoolKitTests
//
//  Created by Larry Kenyon on 9/17/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
@testable import TidepoolKit

class ReachabilityMock: ReachabilitySource {
    var isReachable: Bool { return false }

    func configureNotifier(_ on: Bool) -> Bool {
        return true
    }
}
