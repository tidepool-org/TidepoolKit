//
//  URL.swift
//  
//
//  Created by Pete Schwamb on 5/1/23.
//

import Foundation


extension URL {
    func getAuthURL(clientID: String, challenge: String, urlScheme: String) -> URL? {
        guard var components = URLComponents(string: self.absoluteString) else {
            return nil
        }

        components.queryItems = [
            URLQueryItem(name:"client_id", value: clientID),
            URLQueryItem(name:"redirect_uri", value: urlScheme),
            URLQueryItem(name:"response_type", value: "code"),
            URLQueryItem(name:"scope", value: "email openid profile"),
            URLQueryItem(name:"code_challenge", value: challenge),
            URLQueryItem(name:"code_challenge_method", value: "S256"),
        ]

        return components.url
    }

    func getQueryParam(value: String) -> String? {
        guard let comps = URLComponents(url: self, resolvingAgainstBaseURL: true), let queryItems = comps.queryItems else { return nil }
        return queryItems.filter ({ $0.name == value }).first?.value
    }

}
