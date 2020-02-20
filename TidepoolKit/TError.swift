//
//  TError.swift
//  TidepoolKit
//
//  Created by Darin Krauss on 2/17/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

/// All errors reported by TidepoolKit.
public enum TError: Error {

    /// A general network error not covered by another more specific error. May include a more specific OS-level error.
    case network(Error?)

    /// The server responded that the request received was bad or malformed. Equivalent to HTTP status code 400. May include response body.
    case badRequest(HTTPURLResponse, Data?)

    /// The server responded that the request was not authenticated. Equivalent to HTTP status code 401. May include response body.
    case unauthenticated(HTTPURLResponse, Data?)

    /// The server responded that the request was properly authenticated, but not unauthorized. Equivalent to HTTP status code 403. May include response body.
    case unauthorized(HTTPURLResponse, Data?)

    /// The server responded that the requested resource was not found. Equivalent to HTTP status code 404. May include response body.
    case notFound(HTTPURLResponse, Data?)

    /// The server responded with an unexpected status code. Any status code other than 200-299 and those specified above. May include response body.
    case unexpectedStatusCode(HTTPURLResponse, Data?)

    /// The server response was bad or malformed. May include response body.
    case badResponse(HTTPURLResponse, Data?)

    /// The default localized description of the error.
    public var localizedDescription: String {
        switch self {
        case .network(_):
            return NSLocalizedString("A network error occurred.", comment: "The default localized description of the network error")
        case .badRequest(_):
            return NSLocalizedString("The request was invalid.", comment: "The default localized description of the bad request error")
        case .unauthenticated(_):
            return NSLocalizedString("The request was not authenticated.", comment: "The default localized description of the unauthenticated error")
        case .unauthorized(_):
            return NSLocalizedString("The request was not authorized.", comment: "The default localized description of the unauthorized error")
        case .notFound(_):
            return NSLocalizedString("The request was not found.", comment: "The default localized description of the not found error")
        case .unexpectedStatusCode(_, _):
            return NSLocalizedString("The request returned an unexpected response.", comment: "The default localized description of the unexpected status code error")
        case .badResponse(_):
            return NSLocalizedString("The request returned a malformed response.", comment: "The default localized description of the bad response error")
        }
    }
}
