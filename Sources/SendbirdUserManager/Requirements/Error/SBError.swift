//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/29/24.
//

import Foundation


public enum SBError : Error {
    case userCreateFailed([(SBUser,String)])
    case userFetchFailed(String)
    
    var localizedDescription: String {
        switch self {
        case .userCreateFailed(let users):
            return "userCreateFailed:\(users)"
        case .userFetchFailed(let message):
            return "userFetchFailed: \(message)"
        }
    }
}
