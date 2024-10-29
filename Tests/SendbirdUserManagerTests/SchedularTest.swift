//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation
import XCTest
@testable import SendbirdUserManager

struct MockResponse : Decodable {
    var identifier : Int
    var requestedDate : Date
}
struct MockRequest: Request {
    var urlPath: String {
        return ""
    }
    
    var method: SBHttpMethod {
        return .POST
    }
    
    var parameters: [String : Any]?
    
    typealias Response = MockResponse
    let response : Response
    
    init(response: Response) {
        self.response = response
    }
}

class MockRequestClient : SBNetworkClient {
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        
        let mockRequest = request as! MockRequest
        let session = MockUrlSession(identifier: mockRequest.response.identifier)
        
        let task = session.dataTask { identifier, requestDate  in
            MockSchedular.shared.signalSemaphore()
            completionHandler(.success(
                MockResponse(identifier: mockRequest.response.identifier, requestedDate: requestDate) as! R.Response
            )
            )
        }
        MockSchedular.shared.appendTask(task)
        MockSchedular.shared.executeTask()
    }
}
class MockUrlSession {
    var identifier : Int = -1
    init(identifier: Int) {
        self.identifier = identifier
    }
    
    func dataTask(completionHandler : ((Int,Date) -> ())?) -> MockUrlSessionTask {
        return .init(completionHandler : completionHandler, identifier: identifier)
    }
    
}

class MockUrlSessionTask {
    var completionHandler : ((Int,Date) -> ())?
    var identifier : Int = -1
    init(completionHandler: ( (Int,Date) -> Void)? = nil,identifier : Int) {
        self.identifier = identifier
        self.completionHandler = completionHandler
    }
    func resume(requestDate : Date) {
        let rand = UInt32.random(in: 500_000...1000_000)
        usleep(rand)
        completionHandler?(identifier,requestDate)
    }
}

class MockSchedular : Schedular {
    static let shared = MockSchedular()
    typealias Tasks = MockUrlSessionTask
    var taskQueue : [Tasks] = []
    var lastRequestDate : Date?
    var operationQueue : OperationQueue = OperationQueue()
    var semaphore = DispatchSemaphore(value:0)
    
    private init(){
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    func appendTask(_ task : Tasks) {
        operationQueue.addOperation {
            self.taskQueue.append(task)
        }
    }
    
    func signalSemaphore() {
        semaphore.signal()
    }
    
    func executeTask() {
        operationQueue.addOperation {
            guard !self.taskQueue.isEmpty else { return }
            if let lastRequestDate = self.lastRequestDate {
                let lastRequestDateSeconds = lastRequestDate.timeIntervalSince1970
                let currentRequestDateSeconds = Date().timeIntervalSince1970
                let diff = currentRequestDateSeconds - lastRequestDateSeconds
                let nextTask = self.taskQueue.removeFirst()
                if diff < 1 {
                    usleep(UInt32(diff*1000_000))
                }
                DispatchQueue.global(qos: .background).async {
                    self.lastRequestDate = Date()
                    nextTask.resume(requestDate: self.lastRequestDate ?? Date())
                }
            }
            else {
                let nextTask = self.taskQueue.removeFirst()
                DispatchQueue.global(qos: .background).async {
                    self.lastRequestDate = Date()
                    nextTask.resume(requestDate: self.lastRequestDate ?? Date())
                }
            }
            self.semaphore.wait()
        }
    }
    
}

class SchedularTestCase: XCTestCase {
    
    let mockRequestClient = MockRequestClient()
    
    func test큐에_있는_테스크_전부_소진_테스트() {
        var count : Int = 0
        let expectation = self.expectation(description: "wait for all tasks")
        for i in 0..<10 {
            mockRequestClient.request(request: MockRequest(response: .init(identifier: i, requestedDate: Date()))) { result
                in
                count += 1
                if count == 9 {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 15)
        XCTAssertEqual(0, MockSchedular.shared.taskQueue.count)
    }
    
    func testAPI가_1초_이상마다_호출되는_테스트() {
        var count : Int = 0
        let expectation = self.expectation(description: "wait for all tasks")
        
        var lastRequestDate : Date?
        for i in 0..<10 {
            mockRequestClient.request(request: MockRequest(response: .init(identifier: i, requestedDate: Date()))) { result in
                switch result {
                case .success(let response):
                    if let lastRequestDate = lastRequestDate {
                        let lastRequestDateSeconds = lastRequestDate.timeIntervalSince1970
                        let currentRequestDateSeconds = response.requestedDate.timeIntervalSince1970
                        let diff = currentRequestDateSeconds - lastRequestDateSeconds
                        XCTAssertTrue(diff > 1, "api requested too fast \(diff)")
                    }
                    lastRequestDate = response.requestedDate
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
