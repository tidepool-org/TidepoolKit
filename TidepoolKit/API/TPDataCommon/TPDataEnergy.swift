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

public enum EnergyUnits: String {
    case calories = "calories"
    case kilocalories = "kilocalories" /* (aka dietary Calorie)*/
    case joules = "joules"
    case kilojoules = "kilojoules"
}

public struct Energy {
    public var value: Double         // 0.0 <= x < 10000.0 for kilocalories, converted for other types; 4.1848 joules / calories]
    public var units: EnergyUnits
}


