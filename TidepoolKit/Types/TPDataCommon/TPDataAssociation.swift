//
//  TPDataAssociation.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public enum AssociationType: String {
	case link = "link"
    case datum = "datum"
    case medium = "medium"
    case venue = "venue"
    case food = "food"
}

public struct Association {
	public let type: AssociationType
	public var link: String? = nil		// [url; if and only if type == "link"; 1 <= len <= 2K]
	public var id: String? = nil		// [id; if and only if type == "medium"/"datum"/"venue"/"food"; id to medium/datum/venue/food]
	public var reason: String? 			// why is there this association; 1 <= len <= 1000]
}




