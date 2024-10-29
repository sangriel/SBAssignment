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

struct MockUserUpdateParam : Decodable {
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
       
        if path.contains("/v3/users") {
            if path == "/v3/users" {
                switch httpMethod {
                case "POST": //createUser
                    mockCreatUserAPI()
                default:
                    break
                }
            }
            else {
                switch httpMethod {
                case "PUT":
                    mockPutUserAPI()
                case "GET":
                    parseGetUser()
                default:
                    break
                }
            }
        }
        else {
            switch path {
            case "/test/schedular":
                mockSchedularAPI()
            default:
                break
            }
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
    
    private func mockPutUserAPI() {
        if let userId = extractUserIdFromPath() {// userId를 통한 단일 getUser
            let decoder = JSONDecoder()
            do {
                let body = try decoder.decode(MockUserUpdateParam.self, from: request.httpBody!)
                
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
    }
    
    
    private func parseGetUser() {
        if let userId = extractUserIdFromPath() {// userId를 통한 단일 getUser
            mockGetUserAPI(userId: userId)
        }
        else if let queryParam = queryParameters(from: request) { //nickname을 통한 getListUser
           
        }
    }
    
    private func mockGetUserAPI(userId : String) {
        let response = ["user_id" : userId,
                        "nickname" : UUID().uuidString,
                        "profile_url": UUID().uuidString ]
        
        var responseData : Data?
        if let jsonData = try? JSONEncoder().encode(response) {
            responseData = jsonData
        }
        
        let rand = UInt32.random(in: 500_000...1000_000)
        usleep(rand)
        completionHandler?(responseData, nil, nil)
    }
    
    private func mockGetUserListAPI() {
        if let queryDict = queryParameters(from: request), let nickname = queryDict["nickname"] {
          
            let response = ["users" : ["user_id" : UUID().uuidString,
                                       "nickname" : nickname,
                                       "profile_url": UUID().uuidString ]]
            
            var responseData : Data?
            if let jsonData = try? JSONEncoder().encode(response) {
                responseData = jsonData
            }
            
            let rand = UInt32.random(in: 500_000...1000_000)
            usleep(rand)
            completionHandler?(responseData, nil, nil)
        }
    }
    
    private func queryParameters(from urlRequest: URLRequest) -> [String: String]? {
        guard let url = urlRequest.url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return nil
        }
        
        var parameters: [String: String] = [:]
        for item in queryItems {
            parameters[item.name] = item.value
        }
        return parameters
    }
    
    private func extractUserIdFromPath() -> String? {
        guard let url = request.url else {
            return nil
        }
        let path = url.path()
        let pattern = "/v3/users/(\\w+)"
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: path, range: NSRange(path.startIndex..., in: path))
            
            if let match = results.first,
               let range = Range(match.range(at: 1), in: path) {
                return String(path[range])
            }
        } catch(let error) {
            print("\(error)")
        }
        return nil
    }
}

class MockUrlSession : URLSession {
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
        return MockUrlSessionDataTask(request: request, completionHandler: completionHandler)
    }
}
