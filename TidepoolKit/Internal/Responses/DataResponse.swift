//
//  DataResponse.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/28/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

struct DataResponse: Codable {
    var data: [TDatum]
    var malformed: [String: [String: Any]]

    init(data: [TDatum] = [], malformed: [String: [String: Any]] = [:]) {
        self.data = data
        self.malformed = malformed
    }
    
    init(from decoder: Decoder) throws {
        self.init()
        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            let superDecoder = try container.superDecoder()
            let superContainer = try superDecoder.container(keyedBy: CodingKeys.self)
            do {
                var datum: TDatum?
                let type = try superContainer.decode(TDatum.DatumType.self, forKey: .type)
                switch type {
                case .cbg:
                    datum = try TCBGDatum(from: superDecoder)
                case .food:
                    datum = try TFoodDatum(from: superDecoder)
                default:
                    break // DEPRECATED: Ignore
                }
                if let datum = datum {
                    data.append(datum)
                }
            } catch let error {
                TSharedLogging.error((error as CustomDebugStringConvertible).debugDescription)
                let malformedContainer = try superDecoder.container(keyedBy: JSONCodingKeys.self)
                malformed[String(container.currentIndex)] = try malformedContainer.decode([String: Any].self)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        try data.encode(to: encoder)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case subType
        case deliveryType
    }
}
