//
//  DateUtils.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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
