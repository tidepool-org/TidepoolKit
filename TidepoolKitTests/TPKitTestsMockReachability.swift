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
    var isReachable = false

    func serviceIsReachable() -> Bool {
        return isReachable
    }
    
    func configureNotifier(_ on: Bool) -> Bool {
        return true
    }
}
