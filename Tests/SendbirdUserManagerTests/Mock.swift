//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/29/24.
//

import Foundation
@testable import SendbirdUserManager

struct MockUserCreateParam : Decodable {
    var userId : String
    var nickname : String?
    var profileUrl : String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case nickname = "nickname"
        case profileUrl = "profile_url"
    }
}

struct MockSchedularTestResponse : Decodable {
    var requestedDate : Double
}

struct MockSchedularTestAPI : Request {
    typealias Response = MockSchedularTestResponse
    
    var urlPath: String {
        return "test/schedular"
    }
    
    var method: SBHttpMethod {
        .POST
    }
    
    
    var parameters: [String : Any]? {
        return ["requestedDate" : requestedDate.timeIntervalSince1970]
    }
    
    let requestedDate : Date
    
    init(requestedDate : Date = Date()) {
        self.requestedDate = requestedDate
    }
}

class MockUrlSessionDataTask : URLSessionDataTask {
    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
    let request : URLRequest
    init(request : URLRequest, completionHandler: ( (Data?, URLResponse?, Error?) -> Void)? = nil) {
        self.request = request
        self.completionHandler = completionHandler
    }
    
    override func resume() {
        
        guard let path = request.url?.path else {
            completionHandler?(nil, nil, SBNetworkError.invalidUrl)
            return
        }
        
        let httpMethod = request.httpMethod ?? ""
        print("path \(path)")
        print("method \(httpMethod)")
        
        switch path {
        case "/v3/users":
            switch httpMethod {
            case "POST": //createUser
                mockCreatUserAPI()
            case "DELETE":
                break
            case "PUT"://,upsertUser
                break
            case "GET": //getUser
                break
            default:
                break
            }
        case "/test/schedular":
            mockSchedularAPI()
        default:
            break
        }
        
        
    }
    
    
    private func mockCreatUserAPI() {
        let decoder = JSONDecoder()
        do {
            let body = try decoder.decode(MockUserCreateParam.self, from: request.httpBody!)
            
            let response = ["user_id" : body.userId,
                            "nickname" : body.nickname,
                            "profile_url": body.profileUrl ]
            
            var responseData : Data?
            if let jsonData = try? JSONEncoder().encode(response) {
                responseData = jsonData
            }
            
            let rand = UInt32.random(in: 500_000...1000_000)
            usleep(rand)
            completionHandler?(responseData, nil, nil)
        }
        catch(let error) {
            completionHandler?(nil,nil,error)
        }
    }
    
    private func mockSchedularAPI() {
        let decoder = JSONDecoder()
        do {
            let body = try decoder.decode(MockSchedularTestResponse.self, from: request.httpBody!)
            
            let response = ["requestDate" : body.requestedDate]
            
            var responseData : Data?
            if let jsonData = try? JSONEncoder().encode(response) {
                responseData = jsonData
            }
            
            let rand = UInt32.random(in: 500_000...1000_000)
            usleep(rand)
            completionHandler?(responseData, nil, nil)
        }
        catch(let error) {
            completionHandler?(nil,nil,error)
        }
    }
}

class MockUrlSession : URLSession {
   
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        return MockUrlSessionDataTask(request: request, completionHandler: completionHandler)
    }
}
