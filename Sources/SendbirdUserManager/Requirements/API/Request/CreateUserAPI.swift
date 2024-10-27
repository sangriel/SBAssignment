//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


struct CreateUserRequest : Request {
    typealias Response = UserResponse
    
    var urlPath: String {
        "/v3/users"
    }
    
    var method: SBHttpMethod {
        .POST
    }
    
    var parameters: [String: Any]? {
        return [
            "user_id" : userCreationParam.userId,
            "nickname" : userCreationParam.nickname,
            "profile_url" : userCreationParam.profileURL ?? "https://picsum.photos/seed/picsum/200/300"
        ]
    }
    
    init(usercreationParam: UserCreationParams) {
        self.userCreationParam = usercreationParam
    }
    
    private let userCreationParam : UserCreationParams
}

