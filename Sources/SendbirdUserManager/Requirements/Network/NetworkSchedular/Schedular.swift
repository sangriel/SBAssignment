//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


protocol Schedular {
    associatedtype Tasks
    
    func appendTask(_ task : Tasks)
    func executeTask()
}
