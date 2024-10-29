//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation
import XCTest
@testable import SendbirdUserManager


class SchedularTestCase: XCTestCase {
    
    let mockRequestClient = SBBaseNetworkManager(session: MockUrlSession())
    
    func test큐에_있는_테스크_전부_소진_테스트() {
        var count : Int = 0
        let expectation = self.expectation(description: "wait for all tasks")
        for i in 0..<10 {
            let request = MockSchedularTestAPI()
            mockRequestClient.request(request: request) { result
                in
                count += 1
                if count == 9 {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(0, SBNetworkSchedular.shared.getTaskQueueCount())
    }
    
    func testAPI가_1초_이상마다_호출되는_테스트() {
        var count : Int = 0
        let expectation = self.expectation(description: "wait for all tasks")
        
        var lastRequestDate : Date?
        for i in 0..<10 {
            let request = MockSchedularTestAPI()
            mockRequestClient.request(request: request) { result in
                switch result {
                case .success(let response):
                    if let lastRequestDate = lastRequestDate {
                        let lastRequestDateSeconds = lastRequestDate.timeIntervalSince1970
                        let currentRequestDateSeconds = response.requestedDate
                        let diff = currentRequestDateSeconds - lastRequestDateSeconds
                        XCTAssertTrue(diff > 1, "api requested too fast \(diff)")
                    }
                    lastRequestDate = Date(timeIntervalSince1970: response.requestedDate)
                case .failure(_):
                    break
                }
                count += 1
                if count == 9 {
                    expectation.fulfill()
                }
            }
        }
        wait(for: [expectation], timeout: 15)
    }
    
}
