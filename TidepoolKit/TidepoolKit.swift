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

public enum TidepoolKitError: Error {
    case unauthorized       // http error 401
    case badRequest(_ badSampleIndices: [Int]?) // http error 400
    case badURL
    case badLoginResponse
    case offline
    case notLoggedIn
    case alreadyLoggedIn
    case serviceError       // generic service error...
    case noUploadId         // dataset uploadId is nil!
    case noDataInResponse   // service returned no data
    case badJsonInResponse  // service data was not json parseable into expected object
    case internalError      // some framework error (not service)
    case unimplemented      // temp: unfinished...
}

public enum TidepoolServer: String, RawRepresentable, CaseIterable {
    case development = "Development"
    case staging = "Staging"
    case integration = "Integration"
    case production = "Production"
}

public let TidepoolLogInChangedNotification = Notification.Name("TidepoolLogInChangedNotification")

public class TidepoolKit {
    
    // Returns non-nil if singleton already exists, otherwise nil..
    public static var sharedInstance: TidepoolKit? {
        get {
            return TidepoolKit._sharedInstance
        }
    }
    
    /// Only allows one initialization: this call will fail if an instance has already been created.
    /// - parameter logger: Optional TPKitLogging object that will be called for logging. If nil, no logging will be done.
    public init?(logger: TPKitLogging? = nil) {
        // only allow one initialization, either implicitly via a first sharedInstance call, or via this call...
        if TidepoolKit._sharedInstance != nil {
            return nil
        }
        clientLogger = logger
        self.apiConnect = APIConnector()
        TidepoolKit._sharedInstance = self
    }
    private static var _sharedInstance: TidepoolKit?
    private let apiConnect: APIConnector
    
    public func isConnectedToNetwork() -> Bool {
        return apiConnect.isConnectedToNetwork()
    }
    
    public func isLoggedIn() -> Bool {
        return apiConnect.session != nil
    }
    
    public func loggedInUser() -> TPUser? {
        return apiConnect.loggedInUser()
    }
    
    // same as isLoggedIn but returns the session info...
    public func currentSession() -> TPSession? {
        return apiConnect.session
    }
    
    /// If successful, returns a TPSession containing the TPUser for the account owner, and TidepoolKit will move to logged in state.
    ///
    /// Possible errors:
    /// - unauthorized: bad password or unrecognized user name
    /// - badLoginResponse:
    /// - offline:
    public func logIn(_ email: String, password: String, server: TidepoolServer? = nil, completionHandler: @escaping (Result<TPSession, TidepoolKitError>) -> Void) {
        apiConnect.login(email, password: password, server: server, completion: completionHandler)
    }
    
    // optionally log in from a persisted TPSession...
    public func logIn(_ session: TPSession) -> Result<TPSession, TidepoolKitError> {
        return apiConnect.login(session)
    }
    
    public func logOut() {
        apiConnect.logout()
    }
    
    //
    // MARK: - Tidepool "fetchable" types...
    //

    /// Fetch Tidepool user data records of mixed types that have a date within the range specified (startDate < record date <= endDate).
    /// - parameter startDate: Record date must be later than startDate
    /// - parameter endDate: Record date must be before or equal to endEdate
    /// - parameter objectTypes: One or more of "smbg,bolus,cbg,wizard,basal,food", or nil to fetch all these types.
    /// - parameter completion: async completion to be called when fetch completes successfully or with an error condition.
    public func getUserData(_ user: TPUser, startDate: Date, endDate: Date, objectTypes: String = "smbg,bolus,cbg,wizard,basal,food", _ completion: @escaping (Result<[TPDeviceData], TidepoolKitError>) -> (Void)) {
        var parameters: Dictionary = ["type": objectTypes]
        parameters.updateValue(DateUtils.dateToJSON(startDate), forKey: "startDate")
        parameters.updateValue(DateUtils.dateToJSON(endDate), forKey: "endDate")
        LogInfo("startDate: \(startDate), endData: \(endDate), objectTypes: \(objectTypes)")
        apiConnect.fetch(APIDeviceDataArray.self, user: user, parameters: parameters) {
            result in
            switch result {
            case .success(let tpUserData):
                LogInfo("TPUserDataArray fetch succeeded: \n\(tpUserData)")
                completion(.success(tpUserData.userData))
            case .failure(let error):
                LogError("APIUserDataArray fetch failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    public func putUserData(_ dataset: TPDataset, samples: [TPDeviceData], _ completion: @escaping (Result<Bool, TidepoolKitError>) -> (Void)) {
        guard let uploadId = dataset.uploadId else {
            completion(.failure(.noUploadId))
            return
        }
        let uploadData = APIDeviceDataArray(samples)
        self.apiConnect.upload(uploadData, uploadId: uploadId, httpMethod: "POST") {
            result in
            completion(result)
        }
    }

    public func deleteUserData(_ dataset: TPDataset, samples: [TPDeleteItem], _ completion: @escaping (Result<Bool, TidepoolKitError>) -> (Void)) {
        guard let uploadId = dataset.uploadId else {
            completion(.failure(.noUploadId))
            return
        }
        let deleteItems = APIDeleteItemArray(samples)
        self.apiConnect.upload(deleteItems, uploadId: uploadId, httpMethod: "DELETE") {
            result in
            completion(result)
        }
    }

    public func getUserProfileInfo(_ user: TPUser, _ completion: @escaping (Result<TPUserProfile, TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(TPUserProfile.self, user: user) {
            result in
            completion(result)
        }
    }
    
    public func getUserSettingsInfo(_ user: TPUser, _ completion: @escaping (Result<TPUserProfile, TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(TPUserProfile.self, user: user) {
            result in
            completion(result)
        }
    }
    
    public func getAccessUsers(_ user: TPUser, _ completion: @escaping (Result<APIAccessUsers, TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(APIAccessUsers.self, user: user) {
            result in
            completion(result)
        }
    }
    
    //
    // MARK: - Tidepool service configuration
    //
    public var currentServer: TidepoolServer? {
        return apiConnect.session?.server
    }
    
    //
    // MARK: - Upload configuration
    //
    
    /// Call this to get a TPDataset that can be used to upload or delete data.
    /// - parameter dataSet: Optional. The service is queried to find an existing dataset that matches this; if no existing match is found, a new dataset will be created.
    /// - parameter completion: Called when this operation completes. If successful, a new TPDataset will returned containing a non-nil uploadId value.
    public func getDataset(dataSet: TPDataset? = nil, user: TPUser, _ completion: @escaping (Result<TPDataset, TidepoolKitError>) -> (Void)) {
        apiConnect.getDataset(matching: dataSet, user: user) {
            result in
            completion(result)
        }
    }

    // returns zero or more datasets on success.
    public func getDatasets(user: TPUser, _ completion: @escaping (Result<[TPDataset], TidepoolKitError>) -> (Void)) {
        apiConnect.getDatasets(user: user) {
            result in
            completion(result)
        }
    }

    //
    // MARK: - Misc...
    //
    
    /// Current logging object. Stored as a global private to the framework, and used within the framework for logging. Set to enable/disable logging if changes are desired post-initialization.
    public var logger: TPKitLogging? {
        get {
            return clientLogger
        }
        set {
            clientLogger = newValue
        }
    }
}

// global logging protocol, optional...
var clientLogger: TPKitLogging?

