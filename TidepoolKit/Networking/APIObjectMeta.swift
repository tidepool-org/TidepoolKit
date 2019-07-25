//
//  APIObjectMeta.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

// Private to framework. Used by API to extend baseurl for a get request.
protocol TPFetchable {
    
    static func urlPath(forUser userId: String) -> String
    static func fromJsonData(_ data: Data) -> TPFetchable?
}

extension TPFetchable {
    
    static func dictFromJsonData(_ data: Data) -> [String: Any]? {
        guard let json: Any = try? JSONSerialization.jsonObject(with: data) else {
            LogError("Fetched data not json decodable!")
            return nil
        }
        guard let jsonDict = json as? [String: Any] else {
            LogError("Fetched json not a [String: Any]: \(json)!")
            return nil
        }
        return jsonDict
    }

    static func dictArrayFromJsonData(_ data: Data) -> [[String: Any]]? {
        guard let json: Any = try? JSONSerialization.jsonObject(with: data) else {
            LogError("Fetched data not json decodable!")
            return nil
        }
        guard let jsonDictArray = json as? [[String: Any]] else {
            LogError("Fetched json not a [[String: Any]]: \(json)!")
            return nil
        }
        return jsonDictArray
    }
}

// Private to framework. TPPostable objects are TPFetchable and also take a body.
protocol TPPostable: TPFetchable {
    
    func postBodyData() -> Data?
}

// Private to framework. TPUploadable objects take a body, and can optionally parse an error response.
protocol TPUploadable {
    
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
        guard let postBody = try? JSONSerialization.data(withJSONObject: postBodyDictArray) else {
            LogError("TPUploadable.postBodyData() unable to serialize array \(postBodyDictArray)!")
            return nil
        }
        return postBody
    }

}
