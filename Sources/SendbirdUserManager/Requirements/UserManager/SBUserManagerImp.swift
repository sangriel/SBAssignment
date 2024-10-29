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
                let sbUser = ModelTransformer.createUserApiResponseToSBUser(response)
                self?.upsertUsersAtStorage(users: [sbUser])
                completionHandler?(.success(sbUser))
            case .failure(let error):
                completionHandler?(.failure(error))
            }
        }
    }
    
    func createUsers(params: [UserCreationParams], completionHandler: ((UsersResult) -> Void)?) {
        var successedUser : [SBUser] = []
        var failedUser : [(SBUser,String)] = []
        let requestingUserParams = params.prefix(10)
        let exceededUserParams = Array(params.dropFirst(10))
        failedUser.append(contentsOf: exceededUserParams.map{ (ModelTransformer.createUserParamToSBUser($0),"can not create over 10 users at once") })
        
        let dispatchGroup = DispatchGroup()
        var results : [(Result<CreateUserRequest.Response, Error>,UserCreationParams)] = []
        
        for param in requestingUserParams {
            dispatchGroup.enter()
            let createUserRequest = CreateUserRequest(usercreationParam: param)
            networkClient.request(request: createUserRequest) { result in
                results.append((result,param))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
        
        for result in results {
            switch result.0 {
            case .success(let response):
                let sbUser = ModelTransformer.createUserApiResponseToSBUser(response)
                successedUser.append(sbUser)
                self.upsertUsersAtStorage(users: [sbUser])
            case .failure(let error):
                let sbUser = ModelTransformer.createUserParamToSBUser(result.1)
                let sbErrorResult = (sbUser,error.localizedDescription)
                failedUser.append(sbErrorResult)
            }
        }
        if failedUser.isEmpty {
            completionHandler?(.success(successedUser))
        }
        else {
            completionHandler?(.failure(SBError.userCreateFailed(failedUser)))
        }
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
