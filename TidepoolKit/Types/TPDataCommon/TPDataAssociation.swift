/*
 * Copyright (c) 2019, Tidepool Project
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the associated License, which is identical to the BSD 2-Clause
 * License as published by the Open Source Initiative at opensource.org.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the License for more details.
 *
 * You should have received a copy of the License along with this program; if
 * not, you can obtain one from Tidepool Project at tidepool.org.
 */

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




