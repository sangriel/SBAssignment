//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/29/24.
//

import Foundation


enum SBError : Error {
    case userCreateFailed([(SBUser,String)])
}
