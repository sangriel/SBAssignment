//
//  SendbirdUserManagerTests.swift
//  SendbirdUserManagerTests
//
//  Created by Sendbird
//

import XCTest
@testable import SendbirdUserManager

final class UserManagerTests: UserManagerBaseTests {
    override func userManager() -> SBUserManager {
        SBUserManagerImp()
    }
}

final class UserStorageTests: UserStorageBaseTests {
    override func userStorage() -> SBUserStorage? {
        return SBMemoryStorage()
    }
}
//
//final class NetworkClientTests: NetworkClientBaseTests {
//    override func networkClient() -> SBNetworkClient? {
//        MockNetworkClient()
//    }
//}
