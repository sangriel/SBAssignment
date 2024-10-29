//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/30/24.
//

import Foundation

struct GetUserListAPI : Request {
    typealias Response = UserListResponse
    
    var urlPath: String {
        "/v3/users"
    }
    
    var method: SBHttpMethod {
        .GET
    }
    
    var parameters: [String: Any]? {
        return ["nickname" : nickname,
                "limit" : 100]
    }
    
    init(nickname: String) {
        self.nickname = nickname
    }
    
    private let nickname : String
}
