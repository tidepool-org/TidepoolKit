//
//  TPDeleteItem.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/// Items of this class may be used to delete corresponding tidepool items on the service in lieu of passing regular TPDeviceData objects. Alternately just using an item of base class TPDeviceData would work as well: this class just provides a more convenient initializer that ensures either an id or origin object with id.
/// TPDeleteItem items are only passed up to the service, never downloaded.

public class TPDeleteItem: RawRepresentable {

    public var id: String?
    public var origin: TPDataOrigin?

    /// One parameter must be non-nil, the first non-nil item specified is used to create the object.
    /// - parameter id: for items where the top level id is used for de-duplication on the service.
    /// - parameter originId: for items where the origin id is used for de-duplication on the service (typical).
    /// - parameter origin: optionally pass this if it contains id...
    public init?(origin: TPDataOrigin? = nil, originId: String? = nil, id: String? = nil) {
        if let origin = origin, let _ = origin.id {
            self.origin = origin
        } else if let originId = originId {
            let originWithId = TPDataOrigin(id: originId)
            self.origin = originWithId
        } else if let id = id {
            self.id = id
        } else {
            // require an id somewhere...
            return nil
        }
    }
    
    /// Convenience init to create a TPDeleteItem from an existing TPDeviceData item...
    public init?(_ tpDataItem: TPDeviceData) {
        let originId = tpDataItem.origin?.id
        let id = tpDataItem.id
        if let originId = originId {
            let originWithId = TPDataOrigin(id: originId)
            self.origin = originWithId
        } else if let id = id {
            self.id = id
        } else {
            // require an id somewhere...
            return nil
        }
    }

    //
    // MARK: - RawRepresentable
    //
    public typealias RawValue = [String: Any]

    public required init?(rawValue: [String : Any]) {
        return nil
    }

    public var rawValue: RawValue {
        var result = [String: Any]()
        result["id"] = self.id
        self.origin?.addSelfToDict(&result)
        return result
    }
    
}
