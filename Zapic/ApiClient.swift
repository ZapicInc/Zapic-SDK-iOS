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
    //    case invalidCredentials
    //    case invalidRequest
    //    case notFound
    //    case invalidResponse
    //    case serverError
    //    case serverUnavailable
    //    case timeOut
    //    case unsuppotedURL
}

class ApiClient {

    static let TokenUrl = URL(string: "http://api.zapic.com/v1/game-center/token")

    static func getToken(signature: [String:Any]) -> Observable<[String:Any]> {

        var request = URLRequest(url: TokenUrl!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = ZapicUtils.serialize(data: signature)

        return URLSession.shared.rx.response(request: request).flatMap { (response: HTTPURLResponse, data: Data) -> Observable<[String:Any]> in

            if 200 == response.statusCode,
                let json: [String:Any] = ZapicUtils.deserialize(bodyData: data) {
                return Observable.just(json)
            } else {
                return Observable.error(ZapicError.unknownError)
            }
        }
    }
}

class ZapicUtils {

    static func serialize(data: Any) -> Data? {

        if let dataStr = data as? String {
            return (dataStr).data(using: .utf8)
        }

        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options:.prettyPrinted) {

            return String(data: jsonData, encoding: .utf8)?.data(using: .utf8)
        }
        return nil
    }

    static func deserialize(bodyData: Data) -> [String:Any]? {
        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
            let payload = json as? [String: Any] else {
                return nil
        }
        return payload
    }
}
