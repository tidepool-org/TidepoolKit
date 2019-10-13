//
//  TPKitTestsMockService.swift
//  TidepoolKitTests
//
//  Created by Larry Kenyon on 9/16/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
@testable import TidepoolKit

//  Base test class just inserts itself as the network interface, but calls into the existing network interface
class TestNetworkInterface: TidepoolNetworkInterface {
    
    let tidepoolNetworkInterface: TidepoolNetworkInterface
    
    init(_ tpKit: TidepoolKit) {
        tidepoolNetworkInterface = tpKit.currentNetworkInterface()
        tpKit.configureNetworkInterface(self)
    }
    
    func remove(_ tpKit: TidepoolKit) {
        tpKit.configureNetworkInterface(tidepoolNetworkInterface)
    }
    
    func sendStandardRequest(_ request: URLRequest, completion: @escaping NetworkRequestCompletionHandler) {
        tidepoolNetworkInterface.sendStandardRequest(request, completion: completion)
    }
    
    func sendBackgroundRequest(_ request: URLRequest, body: Data, completion: @escaping NetworkRequestCompletionHandler) {
        tidepoolNetworkInterface.sendBackgroundRequest(request, body: body, completion: completion)
    }
}



