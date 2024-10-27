//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation

enum AppData {
    @UserDefault(key: "APP_ID", defaultValue: "")
    static var appId: String
}
