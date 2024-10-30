//
//  File.swift
//  SendbirdUserManager
//
//  Created by sangmin han on 10/27/24.
//

import Foundation


class SBBaseNetworkManager : SBNetworkClient   {
    var session: URLSession
    
    init(session : URLSession = .shared){
        self.session = session
    }
    
    var baseUrl: String {
        return "https://api-\(AppData.appId).sendbird.com"
    }
    
    func request<R>(request: R, completionHandler: @escaping (Result<R.Response, any Error>) -> Void) where R : Request {
        var urlString = baseUrl
        if request.urlPath.starts(with: "/") {
            urlString += request.urlPath
        } else {
            urlString += "/\(request.urlPath)"
        }
        
        var finalHeaders : [String : String] = [:]
        for (key, value) in request.headers {
            finalHeaders[key] = value
        }
        
        guard var components = URLComponents(string: urlString) else {
            return completionHandler(.failure(SBNetworkError.invalidUrl))
        }
        
        var bodyData: Data? = nil
        
        switch request.method {
        case .GET, .DELETE:
            if let parameters = request.parameters {
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
            
            if let parameters = request.parameters, let jsonData = try?
                JSONSerialization.data(withJSONObject: parameters) {
                bodyData = jsonData
            }
        }
        
        guard let finalURL = components.url else {
            return completionHandler(.failure(SBNetworkError.invalidUrl))
        }
        
        
        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = bodyData
        urlRequest.timeoutInterval = request.timeoutInterval
        
        for (key, value) in finalHeaders {
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        let task = session.dataTask(with: urlRequest) { data, response, error in
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
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 400
            
            if (200...299).contains(statusCode) == false {
                do {
                    let decoder = JSONDecoder()
                    let error = try decoder.decode(BaseErrorResonse.self, from: data)
                    completionHandler(.failure(SBNetworkError.other((message: error.message , code: error.code))))
                }
                catch(let error) {
                    completionHandler(.failure(error))
                }
            }
            else {
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
