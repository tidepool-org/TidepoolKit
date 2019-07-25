//
//  Misc.swift
//  TidepoolKitTest
//
//  Created by Larry Kenyon on 7/1/19.
//  Copyright © 2019 Tidepool. All rights reserved.
//

import Foundation

let tpKitBundle = Bundle(for: TidepoolKit.self)
if let infoDict = tpKitBundle.infoDictionary {
    print(infoDict)
    if let versionString = infoDict["CFBundleShortVersionString"] {
        print("versionString is \(versionString)")
    } else {
        print("version not found!")
    }
}
