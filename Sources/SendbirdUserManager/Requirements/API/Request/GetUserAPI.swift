//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/29/24.
//

import Foundation

struct GetUserAPI : Request {
    typealias Response = UserResponse
    
    var urlPath: String {
        "/v3/users/\(userId)"
    }
    
    var method: SBHttpMethod {
        .GET
    }
    
    var parameters: [String: Any]? {
        return nil
    }
    
    init(userId: String) {
        self.userId = userId
    }
    
    private let userId : String
}

