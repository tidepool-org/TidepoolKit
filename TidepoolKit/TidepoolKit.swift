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
    case badRequest         // http error 400
    case badURL
    case badLoginResponse
    case offline
    case notLoggedIn
    case serviceError       // generic service error...
    case noDataInResponse   // service returned no data
    case badJsonInResponse  // service data was not json parseable into expected object
    case internalError      // some framework error (not service)
    case unimplemented      // temp: unfinished...
}

public let TidepoolLogInChangedNotification = Notification.Name("TidepoolLogInChangedNotification")

public class TidepoolKit {
    
    public static var sharedInstance: TidepoolKit {
        get {
            if let tpKit = TidepoolKit._sharedInstance {
                return tpKit
            }
            return TidepoolKit.init()!
        }
    }
    
    /// Only allows one initialization, either implicitly via a first sharedInstance call, or via this call: will fail if already initialized. Calling this init allows the framework user to provide their own peristence strategy for storing the handful of strings that this framework needs for a logged in user.
    /// - parameter settings: Optional TPKitSetting subclass that will be used to persist strings used by the framework.
    public init?(settings: TPKitSetting.Type? = nil) {
        // only allow one initialization, either implicitly via a first sharedInstance call, or via this call...
        if TidepoolKit._sharedInstance != nil {
            return nil
        }
        let settingsClass = settings ?? TPKitSettingUserDefaults.self
        self.apiConnect = APIConnector(settings: settingsClass)
        TidepoolKit._sharedInstance = self
    }
    private static var _sharedInstance: TidepoolKit?
    private let apiConnect: APIConnector
    
    public func isConnectedToNetwork() -> Bool {
        return apiConnect.isConnectedToNetwork()
    }
    
    public func isLoggedIn() -> Bool {
        return apiConnect.sessionTokenSetting.value != nil
    }
    
    public func loggedInUser() -> TPUser? {
        return apiConnect.loggedInUser()
    }
    
    /// If successful, returns a partly configured TPUser (minus profile and settings info). Login token, userId, and userName (if returned) will be retained, and TidepoolKit will move to logged in state.
    ///
    /// Possible errors:
    /// - unauthorized: bad password or unrecognized user name
    /// - badLoginResponse:
    /// - offline:
    public func logIn(_ email: String, password: String, completionHandler: @escaping (Result<TPUser, TidepoolKitError>) -> Void) {
        apiConnect.login(email, password: password, completion: completionHandler)
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
    public func getUserData(_ startDate: Date, endDate: Date, objectTypes: String = "smbg,bolus,cbg,wizard,basal,food", _ completion: @escaping (Result<TPUserDataArray, TidepoolKitError>) -> (Void)) {
        var parameters: Dictionary = ["type": objectTypes]
        parameters.updateValue(DateUtils.dateToJSON(startDate), forKey: "startDate")
        parameters.updateValue(DateUtils.dateToJSON(endDate), forKey: "endDate")
        LogInfo("\(#function) startDate: \(startDate), endData: \(endDate), objectTypes: \(objectTypes)")
        apiConnect.fetch(TPUserDataArray.self, parameters: parameters) {
            result in
            switch result {
            case .success(let tpUserData):
                LogInfo("TPUserDataArray fetch succeeded: \n\(tpUserData.debugDescription)")
                completion(.success(tpUserData))
            case .failure(let error):
                LogError("APIUserDataArray fetch failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    public func putUserData(_ samples: TPUserDataArray, _ completion: @escaping (Result<Bool, TidepoolKitError>, [Int]?) -> (Void)) {
        self.configureUploadId() {
            guard self.currentUploadId() != nil else {
                // TODO: currentUploadId should really return Result with TidepoolKitError!
                completion(.failure(.serviceError), nil)
                return
            }
            self.apiConnect.upload(samples, httpMethod: "POST") {
                result in
                switch result {
                    case .success(let failedSamples):
                        if failedSamples == nil {
                            completion(.success(true), nil)
                        } else {
                            completion(.failure(.badRequest), failedSamples)
                        }
                    case .failure(let error):
                        completion(.failure(error), nil)
                }
            }
        }
    }

    public func deleteUserData(_ samples: TPUserDataArray, _ completion: @escaping (Result<Bool, TidepoolKitError>) -> (Void)) {
        self.configureUploadId() {
            guard self.currentUploadId() != nil else {
                // TODO: currentUploadId should really return Result with TidepoolKitError!
                completion(.failure(.serviceError))
                return
            }
            let apiSamples = TPUserDataArray(samples.userData, forDelete: true)
            self.apiConnect.upload(apiSamples, httpMethod: "DELETE") {
                result in
                switch result {
                case .success(let failedSamples):
                    if failedSamples == nil {
                        completion(.success(true))
                    } else {
                        completion(.failure(.badRequest))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    
    // TODO: move most of this to APIConnect...
    public func updateLoginUserWithServiceProfileInfo(_ completion: @escaping (Result<TPUser, TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(APIProfile.self) {
            result in
            switch result {
            case .success(let profile):
                LogInfo("profile fetch succeeded!")
                if let updatedUser = self.apiConnect.updateLoggedInUser(profile) {
                    LogVerbose("updated loggedIn user with profile: \n\(updatedUser.debugDescription)")
                   completion(.success(updatedUser))
                } else {
                    completion(.failure(.notLoggedIn))
                }
            case .failure(let error):
                LogError("profile fetch failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    // TODO: move most of this to APIConnect...
    public func updateLoginUserWithServiceSettingsInfo(_ completion: @escaping (Result<TPUser, TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(APIUserSettings.self) {
            result in
            switch result {
            case .success(let settings):
                LogInfo("settings fetch succeeded!")
                if let updatedUser = self.apiConnect.updateLoggedInUser(settings) {
                    LogVerbose("updated loggedIn user with settings: \n\(updatedUser.debugDescription)")
                    completion(.success(updatedUser))
                } else {
                    completion(.failure(.notLoggedIn))
                }
            case .failure(let error):
                LogError("settings fetch failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }

    // TODO: move most of this to APIConnect. Add access users to TPUser, and rename this to updateLoginUserWithAccessUsers. Callback should happen after all profiles have been fetched.
    public func getAccessUsers(_ completion: @escaping (Result<[TPUser], TidepoolKitError>) -> (Void)) {
        apiConnect.fetch(APIAccessUsers.self) {
            result in
            switch result {
            case .success(let accessUsers):
                LogInfo("access users fetch succeeded: \n\(accessUsers.debugDescription)")
                var users: [TPUser] = []
                for id in accessUsers.userIds {
                    if id == self.apiConnect.loggedInUser()?.userId {
                        continue
                    }
                    let user = TPUser(id, userName: nil)
                    users.append(user)
                    self.apiConnect.fetch(APIProfile.self, userId: id) {
                        result in
                        switch result {
                        case .success(let profile):
                            user.updateWithProfileInfo(profile)
                            LogVerbose("updated user: \(user.debugDescription)")
                            break
                        case .failure:
                            break
                        }
                    }
                }
                completion(.success(users))
            case .failure(let error):
                LogError("access users fetch failed! Error: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    //
    // MARK: - Tidepool service configuration
    //
    public var currentService: String {
        return apiConnect.currentService
    }
    
    public let kSortedServerNames = [
        "Development",
        "Staging",
        "Integration",
        "Production"
    ]
    
    public func switchToServer(_ serverName: String) {
        apiConnect.switchToServer(serverName)
    }
    
    //
    // MARK: - Upload configuration, optional!
    //
    
    /// This will initially return nil after login, and will be set after an initial data upload, or after configureUploadId below is called. It will persist until logout is called.
    public func currentUploadId() -> String? {
        return apiConnect.currentUploadId.value
    }

    /// Force current uploadId/dataset to nil. Call configureUploadId to set a new one (otherwise this will be set to default implicitly on a new upload).
    public func resetUploadId() {
        apiConnect.currentUploadId.value = nil
    }

    /// Call this after login or the resetUploadId call (before any uploads) to override default dataset configuration! This will have no effect if an uploadId has already been configured.
    /// - parameter dataSet: Optional, provides ability to override the type of dataset we need. The service is queried to find an existing dataset that matches this; if no existing match is found, a new dataset will be created.
    /// - parameter completion: Called when this operation completes. If successful, currentUploadId() will return a non-nil value.
    /// - If the upload dataset needs to be more dynamic, this would need to be extended: e.g., to support changing it dynamically, or to support multiple upload datasets.
    public func configureUploadId(dataSet: TPDataset? = nil, _ completion: @escaping () -> (Void)) {
        let configDataset = dataSet ?? TPDataset()
        apiConnect.configureUploadId(configDataset, completion)
    }

    

}
