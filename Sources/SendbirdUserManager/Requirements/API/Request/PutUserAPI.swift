//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/30/24.
//

import Foundation
struct PutUserAPI : Request {
    typealias Response = UserResponse
    
    var urlPath: String {
        "/v3/users/\(userUpdateParam.userId)"
    }
    
    var method: SBHttpMethod {
        .PUT
    }
    
    var parameters: [String: Any]? {
        return [
            "user_id" : userUpdateParam.userId,
            "nickname" : userUpdateParam.nickname,
            "profile_url" : userUpdateParam.profileURL ?? "https://picsum.photos/seed/picsum/200/300"
        ]
    }
    
    init(userUpdateParam: UserUpdateParams) {
        self.userUpdateParam = userUpdateParam
    }
    
    private let userUpdateParam : UserUpdateParams
}

