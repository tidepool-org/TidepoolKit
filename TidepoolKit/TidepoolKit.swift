//
//  TidepoolKit.swift
//  TidepoolKit
//
//  Created by Larry Kenyon on 8/23/19.
//  Copyright © 2019 Tidepool Project. All rights reserved.
//

import Foundation

public class TidepoolKit {
    
    /**
     Initialize the framework singleton.
     
     - parameter logger: Optional TPLogging object that will be called for logging. If nil, no logging will be done.
     - parameter queue: Optional dispatch queue to use for completion handling; main queue will be used as a default (rather than a random networking queue). Immediate completions will always be on the current thread.
     - returns: initialized TidepoolKit object.
     */
    public init(logger: TPLogging? = nil,  queue: DispatchQueue = DispatchQueue.main) {
        globalLogger = logger
        self.apiConnect = APIConnector(queue: queue)
    }
    private let apiConnect: APIConnector
    
    /**
     Current logging object. Stored as a global private to the framework, and used within the framework for logging.
     
     Set to enable/disable logging if changes are desired post-initialization. The logger can also be provided with the framework init call.
     */
    public var logger: TPLogging? {
        get {
            return globalLogger
        }
        set {
            globalLogger = newValue
        }
    }

    // MARK: - Login/Logout/connectivity

    /**
     Returns true if the Internet is available; this does not indicate whether the Tidepool service is available however.
     */
    public func isConnectedToNetwork() -> Bool {
        return apiConnect.isConnectedToNetwork()
    }
    
    /**
     Attempts to log the user into the service.
     
     Upon successful login, a TPSession object will be returned, enabling other calls (except data upload/deletion which also requires a dataset).
  
     - parameter email: user's email used for logging in.
     - parameter password: user's password to the Tidepool service.
     - parameter serverHost: The service host to use. HTTPS procotol is implied.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success has a TPSession object containing a valid authorization token and a TPUser representing the account owner, or Result.failure with an error value (e.g., .unauthorized if the service has rejected the email/password).
     */
    public func logIn(with email: String, password: String, serverHost: String, completion: @escaping (_ result: Result<TPSession, TPError>) -> Void) {
        apiConnect.login(with: email, password: password, serverHost: serverHost, completion: completion)
    }
        
    /**
     Calls the service to refresh the auth token, and user email for the current session. This should be called after a login with session: if offline, this might be tried later when network connectivity is restored.
     
     - note: Possible errors:
     - .offline: the network is not available
     - .unauthorized: auth token not valid (e.g., expired, 401 status)

     - parameter session: The session to be refreshed
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with the refreshed TPSession and TPUser (server returned a 200 status), or Result.failure with an error value.
     */
    public func refreshSession(_ session: TPSession, completion: @escaping (_ result: Result<TPSession, TPError>) -> (Void)) {
        apiConnect.refreshToken(for: session, completion)
    }
    
    /**
     Posts a logout message to the server so the authorization token is invalidated.
     
     - parameter session: The session to be logged out.
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with a true value (either already logged out, or server returned a 200 to the logout post), or Result.failure with an error value (e.g., .offline if the network is offline).
     */
    public func logOut(from session: TPSession, completion: @escaping (_ result: Result<Bool, TPError>) -> (Void)) {
        apiConnect.logout(from: session, completion)
    }
    
    // MARK: - User methods

    /**
      Queries the service for all user data records of mixed types that have a date within the range specified (startDate < record date <= endDate).
     
      - parameter user: the user whose data is being accessed.
      - parameter startDate: Record date must be later than startDate
      - parameter endDate: Record date must be before or equal to endEdate
      - parameter objectTypes: One or more of "smbg,bolus,cbg,wizard,basal,food", or nil to fetch all these types.
      - parameter session: The session context
      - parameter completion: async completion to be called when fetch completes successfully or with an error condition. The completion method takes a Result parameter:
      - parameter result: Result.success with an array of TPDeviceData samples, or Result.failure with an error.
     */
    public func getData(for user: TPUser, from startDate: Date, through endDate: Date, objectTypes: String = "smbg,bolus,cbg,wizard,basal,food", with session: TPSession, _ completion: @escaping (_ result: Result<[TPDeviceData], TPError>) -> (Void)) {
        var parameters: Dictionary = ["type": objectTypes]
        parameters.updateValue(DateUtils.dateToJSON(startDate), forKey: "startDate")
        parameters.updateValue(DateUtils.dateToJSON(endDate), forKey: "endDate")
        LogInfo("startDate: \(startDate), endData: \(endDate), objectTypes: \(objectTypes)")
        apiConnect.fetch(TPDeviceDataArray.self, user: user, parameters: parameters, with: session) {
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
     
     - parameter user: The user: typically the session user.
     - parameter session: The session context
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with a TPUserProfile object, or Result.failure with an error value
     */
    public func getProfileInfo(for user: TPUser, with session: TPSession, _ completion: @escaping (_ result: Result<TPUserProfile, TPError>) -> (Void)) {
        apiConnect.fetch(TPUserProfile.self, user: user, with: session) {
            result in
            completion(result)
        }
    }
    
    /**
     Queries the service for user settings information.
     
     - parameter user: The user: typically the logged-in user.
     - parameter session: The session context
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with an optional TPUserSettings object (nil if there are no settings for this user), or Result.failure with an error value
     */
    public func getSettingsInfo(for user: TPUser, with session: TPSession, _ completion: @escaping (_ result: Result<TPUserSettings?, TPError>) -> (Void)) {
        apiConnect.fetch(TPUserSettings.self, user: user, with: session) {
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
     - parameter session: The session context
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with an array of TPUser objects, or Result.failure with an error value
     */
    public func getAccessUsers(for user: TPUser, with session: TPSession, _ completion: @escaping (_ result: Result<[TPUser], TPError>) -> (Void)) {
        apiConnect.fetch(TPAccessUsers.self, user: user, with: session) {
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
    
    // MARK: - Datasets
    
    /**
     Queries the service to find an existing dataset that matches the dataset; if the service returns an array of datasets with no existing match, a new dataset will be created.
    
     This call must be made to get an uploadId enabling device data upload or deletion (see the putData and deleteData calls). The returned TPDataset may be persisted and used on subsequent logins.
     
     - parameter user: The user associated with the dataset; typically the logged-in user.
     - parameter dataSet: The dataset to match (other than the uploadId).
     - parameter session: The session context
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with a TPDataset containing a non-nil uploadId enabling data upload/delete, or Result.failure with an error value.
    */
    public func getDataset(for user: TPUser, matching dataSet: TPDataset, with session: TPSession, _ completion: @escaping (_ result: Result<TPDataset, TPError>) -> (Void)) {
        apiConnect.getDataset(for: user, matching: dataSet, with: session) {
            result in
            completion(result)
        }
    }

    /**
     Queries the service for all existing datasets associated with the user.
     
     This call may be useful for debugging.
     
     - parameter user: The user associated with the datasets; typically the logged-in user.
     - parameter session: The session context
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with an array of TPDatasets, or Result.failure with an error value
     */
    public func getDatasets(for user: TPUser, with session: TPSession, _ completion: @escaping (_ result: Result<[TPDataset], TPError>) -> (Void)) {
        apiConnect.getDatasets(for: user, with: session) {
            result in
            completion(result)
        }
    }

    // MARK: - Dataset methods

    /**
     Sends the device samples to the server, associating them with the provided dataset.
     
     The server will reject all the data if it determines any of the samples are invalid.
     
     - parameter dataset: The dataset that the data belong to: typically one per data source.
     - parameter samples: The device data to be uploaded; these may be a mix of different typea (e.g., carb, cbg, etc.).
     - parameter session: The session context
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with true boolean, or Result.failure with an error value. If the error code is .badRequest, an array of integer indices of the samples rejected by the service as well as the full response data will be included with the error.
     */
    public func putData(samples: [TPDeviceData], into dataset: TPDataset, with session: TPSession, _ completion: @escaping (_ result: Result<Bool, TPError>) -> (Void)) {
        guard let uploadId = dataset.uploadId else {
            completion(.failure(.noUploadId))
            return
        }
        let uploadData = TPDeviceDataArray(samples)
        apiConnect.upload(uploadData, uploadId: uploadId, with: session, httpMethod: "POST") {
            result in
            completion(result)
        }
    }
    
    /**
     Asks the service to delete the data in the dataset with the id's of the TPDeleteItem samples passed.
     
     The call will succeed even if the service does not find any data with the sample id's.
     
     - parameter dataset: The dataset containing the data to be deleted.
     - parameter samples: The dataset that the data belong to: typically one per data source.
     - parameter session: The session context
     - parameter completion: This completion handler takes a Result parameter:
     - parameter result: Result.success with true boolean, or Result.failure with an error value.
     */
    public func deleteData(samples: [TPDeleteItem], from dataset: TPDataset, with session: TPSession, _ completion: @escaping (_ result: Result<Bool, TPError>) -> (Void)) {
        guard let uploadId = dataset.uploadId else {
            completion(.failure(.noUploadId))
            return
        }
        let deleteItems = TPDeleteItemArray(samples)
        apiConnect.upload(deleteItems, uploadId: uploadId, with: session, httpMethod: "DELETE") {
            result in
            completion(result)
        }
    }
}

// global logging object
var globalLogger: TPLogging?

// MARK: - Non-public extension for testing

extension TidepoolKit {

    /**
     Allows test software to pass in a mock TidepoolNetworkInterface and mock the service, enabling service error cases to be tested.
     
     - note: A mock interface can be injected with this method for one or more calls, and then nil passed to revert to using the real service.
     - parameter networkInterface: Protocol object providing an api to networking. Passing nil will revert service to using the standard network interface. Alternatively, currentNetworkInterface() can be used to save the current interface, and configureNetworkInterface() used to restore it after briefly interjecting a mock interface for a particular call.
     */
    func configureNetworkInterface(_ networkInterface: TidepoolNetworkInterface?) {
        apiConnect.configureNetworkInterface(networkInterface)
    }

    func currentNetworkInterface() -> TidepoolNetworkInterface {
        return apiConnect.networkRequestHandler
    }
    
    /**
     Allows test software to pass in a mock Reachability object and control online/offline status, enabling service error cases to be tested.
     
     - note: A mock reachability object can be injected with this method for one or more calls, and then nil passed to revert to using the real reachability object.
     - note: Only the isReachable call needs to be overridden to determine whether TidepoolKit considers the service to online or not.
     - note: TidepoolKit provides for reachability notifications, but these are not used by the test service, so can be ignored for testing purposes.
     - parameter reachability: Object of a class implementing the ReachabilitySource protocol.
     */
    func configureReachability(_ reachability: ReachabilitySource?) {
        apiConnect.configureReachability(reachability)
    }

}
