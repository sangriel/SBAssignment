//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/30/24.
//

import Foundation
struct UserListResponse : Decodable {
    var users : [UserResponse]
    
    enum CodingKeys: String, CodingKey {
        case users = "users"
    }
}
