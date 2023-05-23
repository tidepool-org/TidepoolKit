//
//  TPermissions.swift
//  TidepoolKit
//
//  Created by Pete Schwamb on 5/23/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.

import Foundation

public struct TPermissionFlag: Codable, Equatable {
    public init() {}
}

public struct TPermissions: Codable, Equatable {
    public let note: TPermissionFlag?
    public let upload: TPermissionFlag?
    public let view: TPermissionFlag?

    public init(note: TPermissionFlag? = nil, upload: TPermissionFlag? = nil, view: TPermissionFlag? = nil) {
        self.note = note
        self.upload = upload
        self.view = view
    }
}
