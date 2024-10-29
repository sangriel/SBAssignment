//
//  NetworkClient.swift
//  
//
//  Created by Sendbird
//

import Foundation

public protocol Request {
    associatedtype Response : Decodable
    var urlPath: String { get }
    var method: SBHttpMethod { get }
    var parameters: [String:Any]? { get }
    var timeoutInterval: Double { get }
    var headers: [String:String] { get }
}
extension Request {
    var timeoutInterval: Double {
        return 10
    }
    
    var headers: [String : String] {
        return ["Api-Token" : AppData.apiToken,
                "Content-Type" : "application/json",
                "Accept" : "application/json"]
    }
}

public enum SBNetworkError : Error {
    case invalidUrl
    case emptyResponse
    
    var localizedDescription: String {
        switch self {
        case .invalidUrl:
            return "Invalid URL"
        case .emptyResponse:
            return "Empty Response"
        }
    }
}

public enum SBHttpMethod : String {
    case GET
    case POST
    case DELETE
    case PUT
}

public protocol SBNetworkClient {
   
    var session : URLSession { get }
    /// 리퀘스트를 요청하고 리퀘스트에 대한 응답을 받아서 전달합니다
    func request<R: Request>(
        request: R,
        completionHandler: @escaping (Result<R.Response, Error>) -> Void
    )
}


