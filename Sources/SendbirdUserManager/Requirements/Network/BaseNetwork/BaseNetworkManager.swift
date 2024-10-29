//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


<<<<<<< HEAD
protocol SBBaseNetworkManager : SBAPIDefinition {
    
}
extension SBBaseNetworkManager {
    var baseUrl: String {
        return ""
    }
    
    var parameters: [String : Any]? {
        return nil
    }
    
    var timeoutInterval: Double {
        return 10
=======
class SBBaseNetworkManager : SBNetworkClient   {
    var session: URLSession
    
    init(session : URLSession = .shared){
        self.session = session
    }
    
    var baseUrl: String {
        return "https://api-\(AppData.appId).sendbird.com"
>>>>>>> feature/network
    }
    
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        var urlString = baseUrl
<<<<<<< HEAD
        if urlPath.starts(with: "/") {
            urlString += urlPath
        } else {
            urlString += "/\(urlPath)"
        }
        
        var finalHeaders : [String : String] = [:]
        for (key, value) in headers {
=======
        if request.urlPath.starts(with: "/") {
            urlString += request.urlPath
        } else {
            urlString += "/\(request.urlPath)"
        }
        
        var finalHeaders : [String : String] = [:]
        for (key, value) in request.headers {
>>>>>>> feature/network
            finalHeaders[key] = value
        }
        
        guard var components = URLComponents(string: urlString) else {
            return completionHandler(.failure(SBNetworkError.invalidUrl))
        }
        
        var bodyData: Data? = nil
        
<<<<<<< HEAD
        switch method {
        case .GET, .DELETE:
            if let parameters = parameters {
=======
        switch request.method {
        case .GET, .DELETE:
            if let parameters = request.parameters {
>>>>>>> feature/network
                var queryItems = [URLQueryItem]()
                
                for (key, value) in parameters {
                    let stringValue = String(describing: value)
                    if !stringValue.isEmpty {
                        queryItems.append(.init(name: key, value: stringValue))
                    }
                }
                
                components.queryItems = queryItems
            }
            
        case .POST, .PUT:
<<<<<<< HEAD
            if let parameters = parameters, let jsonData = try?
=======
            if let parameters = request.parameters, let jsonData = try?
>>>>>>> feature/network
                JSONSerialization.data(withJSONObject: parameters) {
                bodyData = jsonData
            }
        }
        
        guard let finalURL = components.url else {
            return completionHandler(.failure(SBNetworkError.invalidUrl))
        }
        
<<<<<<< HEAD
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.httpBody = bodyData
        request.timeoutInterval = timeoutInterval
        
        for (key, value) in finalHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                defer {
                    SBNetworkSchedular.shared.executeTask()
                }
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completionHandler(.failure(SBNetworkError.emptyResponse))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(R.Response.self, from: data)
                    completionHandler(.success(result))
                }
                catch(let error) {
                    completionHandler(.failure(error))
                }
=======
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = bodyData
        urlRequest.timeoutInterval = request.timeoutInterval
        
        for (key, value) in finalHeaders {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            defer {
                SBNetworkSchedular.shared.signalSemaphore()
            }
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(SBNetworkError.emptyResponse))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(R.Response.self, from: data)
                completionHandler(.success(result))
            }
            catch(let error) {
                completionHandler(.failure(error))
>>>>>>> feature/network
            }
        }
        SBNetworkSchedular.shared.appendTask(task)
        SBNetworkSchedular.shared.executeTask()
    }
<<<<<<< HEAD
    
=======
>>>>>>> feature/network
}
