//
//  TPKitTestsMockService.swift
//  TidepoolKitTests
//
//  Created by Larry Kenyon on 9/16/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation
import TidepoolKit

class TestURLSessionSource: URLSessionSource {
    
    func defaultURLSession() -> URLSession {
        NSLog("TestURLSessionSource.\(#function)")
        return .shared
    }
    
    func backgroundURLSession() -> URLSession? {
        NSLog("TestURLSessionSource.\(#function)")
        return uploadSession
    }
    
    func ensureBackgroundSession(_ delegate: URLSessionDelegate) -> URLSession {
        NSLog("TestURLSessionSource.\(#function)")
        if let uploadSession = self.uploadSession {
            return uploadSession
        }
        let configuration = URLSessionConfiguration.background(withIdentifier: self.backgroundUploadSessionIdentifier)
        configuration.timeoutIntervalForResource = 60 // 60 seconds
        let newUploadSession = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        newUploadSession.delegateQueue.maxConcurrentOperationCount = 1 // keep it simple...
        self.uploadSession = newUploadSession
        NSLog("Created upload session...")
        return newUploadSession
    }
    
    func invalidateBackgroundSession() {
        NSLog("TestURLSessionSource.\(#function)")
        self.uploadSession = nil
    }
    
    private var uploadSession: URLSession?
    private let backgroundUploadSessionIdentifier = "UploadSessionId"
}

// We create a partial mock by subclassing the original class
class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}

class URLSessionUploadTaskMock: URLSessionUploadTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?
    
    override func dataTask(
        with request: URLRequest,
        completionHandler: @escaping CompletionHandler
        ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        
        return URLSessionDataTaskMock {
            // WIP: need to parse URL, and return response as appropriate!
            completionHandler(data, nil, error)
        }
    }
    
    // WIP: need to deal with delegate calls!
    override func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> URLSessionUploadTask {
        return URLSessionUploadTaskMock() {
            
        }
    }
}


