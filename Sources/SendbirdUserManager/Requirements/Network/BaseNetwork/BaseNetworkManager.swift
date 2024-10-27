//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


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
    }
    
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        var urlString = baseUrl
        if urlPath.starts(with: "/") {
            urlString += urlPath
        } else {
            urlString += "/\(urlPath)"
        }
        
        var finalHeaders : [String : String] = [:]
        for (key, value) in headers {
            finalHeaders[key] = value
        }
        
        guard var components = URLComponents(string: urlString) else {
            return completionHandler(.failure(SBNetworkError.invalidUrl))
        }
        
        var bodyData: Data? = nil
        
        switch method {
        case .GET, .DELETE:
            if let parameters = parameters {
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
            if let parameters = parameters, let jsonData = try?
                JSONSerialization.data(withJSONObject: parameters) {
                bodyData = jsonData
            }
        }
        
        guard let finalURL = components.url else {
            return completionHandler(.failure(SBNetworkError.invalidUrl))
        }
        
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
                }
            }
        }
        SBNetworkSchedular.shared.appendTask(task)
        SBNetworkSchedular.shared.executeTask()
    }
    
}
