//
//  ApiClient.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/1/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

enum ZapicError: Error {
    case unknownError
    //    case connectionError
        case invalidCredentials
    //    case invalidRequest
    //    case notFound
    //    case invalidResponse
    //    case serverError
    //    case serverUnavailable
    //    case timeOut
    //    case unsuppotedURL
}

class ApiClient {
    
    let apiVersion = "v1"
    
    let urlPrefix:String
    
    let tokenManager:TokenManager
    
    init(tokenManager: TokenManager) {
        urlPrefix = "http://api.zapic.com/\(apiVersion)/"
        self.tokenManager = tokenManager
    }

    func getToken(signature: [String:Any]) -> Observable<[String:Any]> {

        return createRequest(url: "game-center/token", http: "POST", body: signature, token: false)
    }
    
    func sendActivity(_ activity: Activity) -> Observable<[String:Any]> {
        return createRequest(url: "profile/activities", http: "POST", body: activity, token: true)
    }
    
    private func createRequest(url:String,http:String,body:Any,token:Bool) -> Observable<[String:Any]> {
        
        if token && !tokenManager.hasValidToken() {
            print("Invalid api token, unable to send request")
            return Observable.error(ZapicError.invalidCredentials)
        }
        
        var request = URLRequest(url: URL(string: urlPrefix + url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = ZapicUtils.serialize(data: body)?.data(using: .utf8)
        
        if token{
            request.addValue("Bearer \(tokenManager.token)", forHTTPHeaderField: "Authorization")
        }
        
        print("Sending HTTP request to \(url)")
        
        return URLSession.shared.rx.response(request: request).map { (response: HTTPURLResponse, data: Data) in
            
            print("Received API Response \(response.statusCode) from \(url)")
            
            if 200 == response.statusCode,
                let json: [String:Any] = ZapicUtils.deserialize(bodyData: data) {
                return json
            } else {
                throw ZapicError.unknownError
            }
        }
    }
}
