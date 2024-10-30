//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/29/24.
//

import Foundation
import XCTest

@testable import SendbirdUserManager



class NetworkResponseTest : XCTestCase {
    
    public let applicationId = "DEE4833A-1FBB-46D5-ABDE-D429AF9FCCE0"   // Note: add an application ID
    public let apiToken = "977131ed68283a22d1fcb28859dbb69e65bdbf59"        // Note: add an API Token
    
    private let networkClient = SBBaseNetworkManager()
    
    
    func testCreateUserAPI() {
        AppData.apiToken = apiToken
        AppData.appId = applicationId
        let expectation = expectation(description: "user create api test")
        let request = CreateUserAPI(usercreationParam: .init(userId: "test1", nickname: "testNickname", profileURL: "https://picsum.photos/seed/picsum/200/300"))
        networkClient.request(request: request) { result  in
            switch result {
            case .success(let response):
                dump(response)
            case .failure(let error):
                dump(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation],timeout: 2)
    }
    
    func testGetUserAPI() {
        AppData.apiToken = apiToken
        AppData.appId = applicationId
        let expectation = expectation(description: "get user api test")
        let request = GetUserAPI(userId: "test1")
        networkClient.request(request: request) { result  in
            switch result {
            case .success(let response):
                dump(response)
            case .failure(let error):
                dump(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation],timeout: 2)
    }
    
    
    func testGetUserListAPI() {
        AppData.apiToken = apiToken
        AppData.appId = applicationId
        let expectation = expectation(description: "get user list api test")
        let request = GetUserListAPI(nickname: "test1")
        networkClient.request(request: request) { result  in
            switch result {
            case .success(let response):
                dump(response)
            case .failure(let error):
                dump(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation],timeout: 2)
    }
    
    
    func testUpdateUserAPI() {
        AppData.apiToken = apiToken
        AppData.appId = applicationId
        let expectation = expectation(description: "get user list api test")
        
        let updateParam = UserUpdateParams(userId: "1", nickname: "update", profileURL: "dkdkdkd")
        let request = PutUserAPI(userUpdateParam: updateParam)
        networkClient.request(request: request) { result  in
            switch result {
            case .success(let response):
                dump(response)
            case .failure(let error):
                dump(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation],timeout: 2)
    }
    
    func testNetworkError() {
        AppData.apiToken = ""
        AppData.appId = applicationId
        let expectation = expectation(description: "network error test")
        let request = GetUserAPI(userId: "")
        networkClient.request(request: request) { result  in
            switch result {
            case .success(let response):
                dump(response)
            case .failure(let error):
                if let error = error as? SBNetworkError {
                    print(error.localizedDescription)
                }
                dump(error)
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation],timeout: 2)
    }
}
