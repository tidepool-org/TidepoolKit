//
//  Data.swift
//  
//
//  Created by Pete Schwamb on 5/1/23.
//  Copyright © 2023 Tidepool Project. All rights reserved.
//

import Foundation

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let jsonAsString = String(data: data, encoding:.utf8) else { return nil }

        return jsonAsString
    }
}
