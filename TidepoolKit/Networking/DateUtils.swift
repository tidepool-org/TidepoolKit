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

class DateUtils {
    
    class func dateFromJSON(_ json: String?) -> Date? {
        if let json = json {
            var result = jsonDateFormatter.date(from: json)
            if result == nil {
                result = jsonAltDateFormatter.date(from: json)
            }
            return result
        }
        return nil
    }
    
    class func dateToJSON(_ date: Date) -> String {
        return jsonDateFormatter.string(from: date)
    }

    class var jsonDateFormatter : DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(identifier: "GMT")
                return dateFormatter
            }()
        }
        return Static.instance
    }

    class var jsonAltDateFormatter : DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                dateFormatter.timeZone = TimeZone(identifier: "GMT")
                return dateFormatter
            }()
        }
        return Static.instance
    }

    
}
