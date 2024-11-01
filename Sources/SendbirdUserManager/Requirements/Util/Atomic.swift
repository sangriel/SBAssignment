//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation

final class Atomic<A> {
    private let queue = DispatchQueue(label: "com.sendbird.atomic")
    private var _value: A
    
    init(_ value: A) {
        self._value = value
    }

    var value: A {
        get {
            return queue.sync { self._value }
        }
    }

    func mutate(_ transform: (inout A) -> ()) {
        queue.sync {
            transform(&self._value)
        }
    }
}
