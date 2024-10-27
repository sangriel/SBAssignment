//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


struct UserResponse : Decodable {
    var userId : String
    var nickname : String?
    var profileUrl : String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname = "nickname"
        case profileUrl = "profile_url"
    }
}
