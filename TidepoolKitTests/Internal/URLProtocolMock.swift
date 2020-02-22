//
//  URLProtocolMock.swift
//  TidepoolKitTests
//
//  Created by Darin Krauss on 3/5/20.
//  Copyright © 2020 Tidepool Project. All rights reserved.
//

import Foundation
import XCTest

class URLProtocolMock: URLProtocol {
    static var validator: Validator?
    static var error: Error?
    static var success: Success?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.validator?.validate(request: request)

        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else if let url = request.url, let success = Self.success, let urlResponse = success.response(for: url) {
            client?.urlProtocol(self, didReceive: urlResponse, cacheStoragePolicy: .notAllowed)
            if let body = success.body {
                client?.urlProtocol(self, didLoad: body)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    struct Validator {
        let url: URL
        let method: String
        let headers: [String: String]?
        let body: Data?

        init(url: String, method: String, headers: [String: String]? = nil, body: Data? = nil) {
            self.url = URL(string: url)!
            self.method = method
            self.headers = headers
            self.body = body
        }

        init<E>(url: String, method: String, headers: [String: String]? = nil, body: E) where E: Encodable {
            self.init(url: url, method: method, headers: headers, body: try? JSONEncoder.tidepool.encode(body))
        }

        func validate(request: URLRequest) {
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, method)
            if let headers = headers {
                XCTAssertNotNil(request.allHTTPHeaderFields)
                if let allHTTPHeaderFields = request.allHTTPHeaderFields {
                    for (key, value) in headers {
                        XCTAssertEqual(allHTTPHeaderFields[key], value)
                    }
                }
            }
            if let body = body {
                if let httpBodyStream = request.httpBodyStream {
                    XCTAssertEqual(Data(from: httpBodyStream), body)
                } else {
                    XCTAssertEqual(request.httpBody, body)
                }
            }
        }
    }

    struct Success {
        var statusCode: Int
        var headers: [String: String]?
        var body: Data?

        init(statusCode: Int, headers: [String: String]? = nil, body: Data? = nil) {
            self.statusCode = statusCode
            self.headers = headers
            self.body = body
        }

        init<E>(statusCode: Int, headers: [String: String]? = nil, body: E) where E: Encodable {
            self.init(statusCode: statusCode, headers: headers, body: try? JSONEncoder.tidepool.encode(body))
        }

        mutating func set<E>(body: E) where E: Encodable {
            self.body = try? JSONEncoder.tidepool.encode(body)
        }

        func response(for url: URL) -> URLResponse? {
            return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: headers)
        }
    }
}

fileprivate extension Data {
    private static let bufferSize = 2048

    init?(from inputStream: InputStream) {
        self.init()

        inputStream.open()
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: Self.bufferSize)
        while inputStream.hasBytesAvailable {
            let bytesRead = inputStream.read(buffer, maxLength: Self.bufferSize)
            guard bytesRead >= 0 else {
                return nil
            }
            self.append(buffer, count: bytesRead)
        }
        buffer.deallocate()
        inputStream.close()
    }
}
