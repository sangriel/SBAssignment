//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/29/24.
//

import Foundation

struct ModelTransformer {
    static func userApiResponseToSBUser(_ user: UserResponse) -> SBUser {
        return .init(userId: user.userId, nickname: user.nickname, profileURL: user.profileUrl)
    }
    
    static func createUserParamToSBUser(_ param : UserCreationParams) -> SBUser {
        return .init(userId: param.userId, nickname: param.nickname, profileURL: param.profileURL)
    }
}
