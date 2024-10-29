//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation



class SBMemoryStorage : SBUserStorage {
    private var users: Atomic<[SBUser]> = .init([])
    private var customQueue = DispatchQueue(label: "com.sendbird.user.memory.storage",qos: .background)
    
    func upsertUser(_ user: SBUser) {
        
        if let targetUserIndex = users.value.firstIndex(where: { $0.userId == user.userId }) {
            users.mutate { item in
                item.remove(at: targetUserIndex)
                item.insert(user, at: targetUserIndex)
            }
        }
        else {
            users.mutate { $0.append(user) }
        }
    }
    
    func getUsers() -> [SBUser] {
        return users.value
    }
    
    func getUsers(for nickname: String) -> [SBUser] {
        return users.value.filter{ $0.nickname == nickname }
    }
    
    func getUser(for userId: String) -> (SBUser)? {
        return users.value.first{ $0.userId == userId }
    }
    
    func removeAllDatas() {
        users.mutate { $0.removeAll() }
    }
}
