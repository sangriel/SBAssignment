//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


class SBUserManagerImp : SBUserManager {
    var networkClient: any SBNetworkClient
    
    var userStorage: any SBUserStorage
    
    init(networkClient: any SBNetworkClient = SBBaseNetworkManager(), userStorage: any SBUserStorage = SBMemoryStorage()) {
        self.networkClient = networkClient
        self.userStorage = userStorage
    }
    
    func initApplication(applicationId: String, apiToken: String) {
        let oldAppId = AppData.appId
        if oldAppId != applicationId {
            //TODO: - remove all data
            userStorage.removeAllDatas()
        }
        AppData.appId = applicationId
        AppData.apiToken = apiToken
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        let createUserRequest = CreateUserRequest(usercreationParam: params)
        networkClient.request(request: createUserRequest) { [weak self] result in
            switch result {
            case .success(let response):
                let sbUser = response.toSBUser()
                self?.upsertUsersAtStorage(users: [sbUser])
                completionHandler?(.success(sbUser))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        
    }
    
    func updateUser(params: UserUpdateParams, completionHandler: ((UserResult) -> Void)?) {
        
    }
    
    func getUser(userId: String, completionHandler: ((UserResult) -> Void)?) {
        
    }
    
    func getUsers(nicknameMatches: String, completionHandler: ((UsersResult) -> Void)?) {
        
    }
}
extension SBUserManagerImp {
    private func upsertUsersAtStorage(users : [SBUser]) {
        for user in users {
            userStorage.upsertUser(user)
        }
    }
}
