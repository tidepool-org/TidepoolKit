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

func jsonToObject<T: Decodable>(_ data: Data) -> T? {
    let decoder = JSONDecoder()
    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        return nil
    }
}

func objectToJson<T: Encodable>(_ object: T) -> Data? {
    let encoder = JSONEncoder()
    do {
        return try encoder.encode(object)
    } catch {
        return nil
    }
}

// Private to framework...
protocol TPFetchable {
    
    //
    // MARK: - TPFetchable protocol conformance methods
    //

    // Used by API to extend baseurl for a get request
    static func urlExtension(forUser userId: String) -> String
    static func fromJsonData(_ data: Data) -> TPFetchable?
}

// Private to framework...
protocol TPPostable: TPFetchable {
    
    //
    // MARK: - TPPostable protocol conformance methods
    //
    
    // TPPostable objects also take a body...
    func postBodyData() -> Data?
}

// Private to framework...
protocol TPUploadable {
    
    //
    // MARK: - TPUploadable protocol conformance methods
    //
    
    // TPUploadable objects take a body...
    func postBodyData() -> Data?
    // And can parse 400 error responses into an array of indices indicating which upload samples were rejected...
    func parseErrResponse(_ response: Data) -> [Int]?
}

