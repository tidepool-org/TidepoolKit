//
//  TidepoolKit.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

/**
 Many calls return Result.failure on failures, with a TidepoolKitError.
 */
public enum TidepoolKitError: Error {
    case unauthorized                               // http error 401
    case badRequest(_ badSampleIndices: [Int]?)     // http error 400
    case dataNotFound                               // http error 404 (may be turned into a successful nil object return)
    case badLoginResponse(_ description: String?)   // login failures other than .unauthorized
    case offline                                    // network unavailable
    case notLoggedIn                                // call requires login
    case alreadyLoggedIn                            // login with Session requires logged out state!
    case serviceError(_ statusCode: Int?)           // service error, status code if available
    case noUploadId                                 // dataset uploadId is nil!
    case noDataInResponse                           // service returned no data in fetch or post
    case badJsonInResponse                          // service data was not json parseable into expected object
    case internalError                              // some framework error (not service)
    case unimplemented                              // used for any unfinished feaures...
}

/**
 Servers available to login. TidepoolServer.allCases returns an array of the available enums.
 */
public enum TidepoolServer: String, RawRepresentable, CaseIterable {
    case development = "Development"
    case staging = "Staging"
    case integration = "Integration"
    case production = "Production"
}

public let TidepoolLogInChangedNotification = Notification.Name("TidepoolLogInChangedNotification")

public class TidepoolKit {
    
    /**
     Initialize the framework singleton.
     
     - parameter logger: Optional TPKitLogging object that will be called for logging. If nil, no logging will be done.
     - returns: initialized TidepoolKit object.
     */
    public init(logger: TPKitLogging? = nil) {
        clientLogger = logger
        self.apiConnect = APIConnector()
    }
    private let apiConnect: APIConnector
    
    /**
     Current logging object. Stored as a global private to the framework, and used within the framework for logging.
     
     Set to enable/disable logging if changes are desired post-initialization. The logger can also be provided with the framework init call.
     */
    public var logger: TPKitLogging? {
        get {
            return clientLogger
        }
        set {
            clientLogger = newValue
        }
    }

    //
    // MARK: - Login/session/connectivity
    //

    /**
     Returns true if the Internet is available; this does not indicate whether the Tidepool service is available however.
     */
    public func isConnectedToNetwork() -> Bool {
        return apiConnect.isConnectedToNetwork()
    }
    
    /**
     Returns true if there is a current TPSession object. Note that the session may have expired, and require a new login.
     */
    public func isLoggedIn() -> Bool {
        return apiConnect.session != nil
    }
    
    /**
     If logged in, returns the current logged in user, otherwise nil.
     */
    public var loggedInUser: TPUser? {
        return apiConnect.loggedInUser()
    }
    
    /**
     If logged in, returns the current session object. As an alternative to the isLoggedIn() call check this for nil.
     */
    public var currentSession: TPSession? {
        return apiConnect.session
    }
    
    /**
     The server for the current session (e.g., staging, production, etc). Note that the TidepoolServer enum can be iterated to discover the available servers. The server is specified at login time.
     */    public var currentServer: TidepoolServer? {
        return apiConnect.session?.server
    }
    
    /**
     Attempts to log the user into the service.
     
     Upon successful login, TidepoolKit will be in a "logged in" state, enabling other calls (except data upload/deletion which also requires a dataset).
  
     - note: If login is successful, this will also result in a TidepoolLogInChangedNotification notification being sent.

     - parameter email: user's email used for logging in.
     - parameter password: user's password to the Tidepool service.
     - parameter server: The service server to use, defaults to .staging.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success has a TPSession object containing a valid authorization token and a TPUser representing the account owner, or Result.failure with an error value (e.g., .unauthorized if the service has rejected the email/password).
     */
    public func logIn(with email: String, password: String, server: TidepoolServer? = nil, completion: @escaping (_ result: Result<TPSession, TidepoolKitError>) -> Void) {
        apiConnect.login(with: email, password: password, server: server, completion: completion)
    }
    
    /**
     Uses the supplied TPSession object to move to logged in state.
 
     Upon successful login, TidepoolKit will be in a "logged in" state, enabling other calls (except data upload/deletion which also requires a dataset).
 
     - parameter session: previous TPSession object to use for login information. This object is retained by TidepoolKit until logout.
     - note: If login is successful, this will also result in a TidepoolLogInChangedNotification notification being sent.
     
     - returns: Result.success with the same TPSession object passed in, or Result.failure of .alreadyLoggedIn if TidepoolKit was already logged in (call logout() first!).
     */
    public func logIn(with session: TPSession) -> Result<TPSession, TidepoolKitError> {
        return apiConnect.login(with: session)
    }
    
    /**
     Calls the service to refresh the auth token for the current session. This should be called after a login with session: if offline, this might be tried later when network connectivity is restored.
     
     - note: If result is .unauthorized, this will change the logged-in state of TidepoolKit to logged out.
     - note: Possible errors:
     - .offline: the network is not available
     - .notLoggedIn: no current session (i.e., no auth token)
     - .unauthorized: auth token not valid (e.g., expired, 401 status)

     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with a true value (server returned a 200 status), or Result.failure with an error value.
     */
    public func refreshSession(completion: @escaping (_ result: Result<Bool, TidepoolKitError>) -> (Void)) {
        apiConnect.refreshToken(completion)
    }
    
    /**
     Immediately clears the TPSession currently retained, if any. Posts a logout message to the server so the authorization token is invalidated. Subsequent calls requiring an authorization token will fail with a .notLoggedIn error.
     
     - note: The session will be cleared even if the network is offline, or if the logout post fails.
     - note: If TidepoolKit was in a logged-in state, this will also result in a TidepoolLogInChangedNotification notification being sent.
     
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with a true value (either already logged out, or server returned a 200 to the logout post), or Result.failure with an error value (e.g., .offline if the network is offline).
     */
    public func logOut(completion: @escaping (_ result: Result<Bool, TidepoolKitError>) -> (Void)) {
        apiConnect.logout(completion)
    }
    
    //
    // MARK: - User methods
    //

    /**
      Queries the service for all user data records of mixed types that have a date within the range specified (startDate < record date <= endDate).
     
      - parameter user: the user whose data is being accessed.
      - parameter startDate: Record date must be later than startDate
      - parameter endDate: Record date must be before or equal to endEdate
      - parameter objectTypes: One or more of "smbg,bolus,cbg,wizard,basal,food", or nil to fetch all these types.
      - parameter completion: async completion to be called when fetch completes successfully or with an error condition. The completion method takes a Result parameter:
      - parameter result: Result.success with an array of TPDeviceData samples, or Result.failure with an error.
     */
    public func getData(for user: TPUser, startDate: Date, endDate: Date, objectTypes: String = "smbg,bolus,cbg,wizard,basal,food", _ completion: @escaping (_ result: Result<[TPDeviceData], TidepoolKitError>) -> (Void)) {
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
    
    /**
     Queries the service for user profile information.
     
     - parameter user: The user: typically the logged-in user.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with a TPUserProfile object, or Result.failure with an error value
     */
    public func getProfileInfo(for user: TPUser, _ completion: @escaping (_ result: Result<TPUserProfile, TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(TPUserProfile.self, user: user) {
            result in
            completion(result)
        }
    }
    
    /**
     Queries the service for user settings information.
     
     - parameter user: The user: typically the logged-in user.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with an optional TPUserSettings object (nil if there are no settings for this user), or Result.failure with an error value
     */
    public func getSettingsInfo(for user: TPUser, _ completion: @escaping (_ result: Result<TPUserSettings?, TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(TPUserSettings.self, user: user) {
            result in
            switch result {
            case .success(let settings):
                completion(.success(settings))
                break
            case .failure(let error):
                if case .dataNotFound = error {
                    completion(.success(nil))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /**
     Queries the service for users who may access the logged in user's data.
     
     - parameter user: The user: typically the logged-in user.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with an array of TPUser objects, or Result.failure with an error value
     */
    public func getAccessUsers(for user: TPUser, _ completion: @escaping (_ result: Result<[TPUser], TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(APIAccessUsers.self, user: user) {
            result in
            switch result {
            case .success(let accessUsers):
                completion(.success(accessUsers.users))
                break
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    //
    // MARK: - Datasets
    //
    
    /**
     Queries the service to find an existing dataset that matches the dataset; if the service returns an array of datasets with no existing match, a new dataset will be created.
    
     This call must be made to get an uploadId enabling device data upload or deletion (see the putData and deleteData calls). The returned TPDataset may be persisted and used on subsequent logins.
     
     - parameter user: The user associated with the dataset; typically the logged-in user.
     - parameter dataSet: The dataset to match (other than the uploadId).
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with a TPDataset containing a non-nil uploadId enabling data upload/delete, or Result.failure with an error value.
    */
    public func getDataset(for user: TPUser, matching dataSet: TPDataset, _ completion: @escaping (_ result: Result<TPDataset, TidepoolKitError>) -> (Void)) {
        apiConnect.getDataset(for: user, matching: dataSet) {
            result in
            completion(result)
        }
    }

    /**
     Queries the service for all existing datasets associated with the user.
     
     This call may be useful for debugging.
     
     - parameter user: The user associated with the datasets; typically the logged-in user.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with an array of TPDatasets, or Result.failure with an error value
     */
    public func getDatasets(for user: TPUser, _ completion: @escaping (_ result: Result<[TPDataset], TidepoolKitError>) -> (Void)) {
        apiConnect.getDatasets(user: user) {
            result in
            completion(result)
        }
    }

    //
    // MARK: - Dataset methods
    //

    /**
     Sends the device samples to the server, associating them with the provided dataset.
     
     The server will reject all the data if it determines any of the samples are invalid.
     
     - parameter dataset: The dataset that the data belong to: typically one per data source.
     - parameter samples: The device data to be uploaded; these may be a mix of different typea (e.g., carb, cbg, etc.).
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with true boolean, or Result.failure with an error value. If the error code is .badRequest, an array of integer indices of the samples rejected by the service will be included with the error.
     */
    public func putData(samples: [TPDeviceData], into dataset: TPDataset, _ completion: @escaping (_ result: Result<Bool, TidepoolKitError>) -> (Void)) {
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
    
    /**
     Asks the service to delete the data in the dataset with the id's of the TPDeleteItem samples passed.
     
     The call will succeed even if the service does not find any data with the sample id's.
     
     - parameter dataset: The dataset containing the data to be deleted.
     - parameter samples: The dataset that the data belong to: typically one per data source.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with true boolean, or Result.failure with an error value.
     */
    public func deleteData(samples: [TPDeleteItem], from dataset: TPDataset, _ completion: @escaping (_ result: Result<Bool, TidepoolKitError>) -> (Void)) {
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
    
}

// global logging object
var clientLogger: TPKitLogging?

extension TidepoolKit {
    
    //
    // MARK: - Non-public extentions for testing
    //
    
    /**
     Clears the TPSession currently retained, if any. Subsequent calls requiring an authorization token will fail with a .notLoggedIn error.
     
     - note: Does NOT send logout to server, so any peristed auth token will remain valid.
     - note: If TidepoolKit was in a logged-in state, this will also result in a TidepoolLogInChangedNotification notification being sent.
     */
    func clearSession() {
        apiConnect.clearSession()
    }
}
