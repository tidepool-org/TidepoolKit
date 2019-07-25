//
//  TPError.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 10/13/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/**
 Many calls return Result.failure on failures, with a TPError.
 */
public enum TPError: Error {
    case unauthorized                               // http error 401
    case badRequest(_ badSampleIndices: [Int]?, response: Data) // http error 400
    case dataNotFound                               // http error 404 (may be turned into a successful nil object return)
    case badLoginResponse(_ description: String?)   // login failures other than .unauthorized
    case offline                                    // network unavailable
    case serviceError(_ statusCode: Int?)           // service error, status code if available
    case noUploadId                                 // dataset uploadId is nil!
    case noDataInResponse                           // service returned no data in fetch or post
    case badJsonInResponse                          // service data was not json parseable into expected object
    case internalError                              // some framework error (not service)
}

