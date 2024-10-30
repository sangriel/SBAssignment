//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/30/24.
//

import Foundation

struct BaseErrorResonse : Decodable {
    let message : String
    let code : Int
    let error : Bool
}
