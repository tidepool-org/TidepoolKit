//
//  APIObjectMeta.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

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

extension TPUploadable {
    func postBodyData<T: RawRepresentable>(_ items: [T]) -> Data? {
        guard !items.isEmpty else {
            LogError("TPUploadable.postBodyData() array is empty!")
            return nil
        }
        var postBodyDictArray: [[String: Any]] = []
        for item in items {
            postBodyDictArray.append(item.rawValue as! [String : Any])
        }
        guard !postBodyDictArray.isEmpty else {
            LogError("TPUploadable.postBodyData() no valid samples!")
            return nil
        }
        guard JSONSerialization.isValidJSONObject(postBodyDictArray) else {
            LogError("TPUploadable.postBodyData() invalid json object: \(postBodyDictArray)!")
            return nil
        }
        do {
            let postBody = try JSONSerialization.data(withJSONObject: postBodyDictArray)
            return postBody
        } catch {
            LogError("TPUploadable.postBodyData() unable to serialize array \(postBodyDictArray)!")
            return nil
        }
    }

}
