//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


final class SBNetworkSchedular : Schedular {
    static let shared = SBNetworkSchedular()
    typealias Tasks = URLSessionDataTask
    private var taskQueue : [URLSessionDataTask] = []
    private var lastRequestDate : Date?
    private var operationQueue : OperationQueue = OperationQueue()
    private var semaphore = DispatchSemaphore(value:0)
    
    private init(){
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    func appendTask(_ task : Tasks) {
        operationQueue.addOperation {
            self.taskQueue.append(task)
        }
    }
    
    func getTaskQueueCount() -> Int {
        return taskQueue.count
    }
    
    func signalSemaphore() {
        semaphore.signal()
    }
    
    func executeTask() {
        operationQueue.addOperation {
            if let lastRequestDate = self.lastRequestDate {
                guard !self.taskQueue.isEmpty else { return }
                let lastRequestDateSeconds = lastRequestDate.timeIntervalSince1970
                let currentRequestDateSeconds = Date().timeIntervalSince1970
                let diff = currentRequestDateSeconds - lastRequestDateSeconds
                let nextTask = self.taskQueue.removeFirst()
                if diff < 1 {
                    usleep(UInt32(diff*1000_000))
                }
                DispatchQueue.global(qos: .background).async {
                    self.lastRequestDate = Date()
                    nextTask.resume()
                }
            }
            else {
                let nextTask = self.taskQueue.removeFirst()
                DispatchQueue.global(qos: .background).async {
                    self.lastRequestDate = Date()
                    nextTask.resume()
                }
            }
            self.semaphore.wait()
        }
    }
    
}
