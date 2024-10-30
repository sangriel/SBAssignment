//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/30/24.
//

import Foundation

public enum SBNetworkError : Error {
    case invalidUrl
    case emptyResponse
    case other((message : String,code : Int))
    var localizedDescription: String {
        switch self {
        case .invalidUrl:
            return "Invalid URL"
        case .emptyResponse:
            return "Empty Response"
        case .other((let message, let code)):
            return "msg : \(message), code : \(code)"
        }
    }
}
