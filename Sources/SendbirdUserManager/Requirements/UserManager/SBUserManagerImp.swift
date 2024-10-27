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
    
    init(networkClient: any SBNetworkClient, userStorage: any SBUserStorage) {
        self.networkClient = networkClient
        self.userStorage = userStorage
    }
    
    func initApplication(applicationId: String, apiToken: String) {
        
    }
    
    func createUser(params: UserCreationParams, completionHandler: ((UserResult) -> Void)?) {
        
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
