//
//  ApiClient.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/1/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

class ApiClient {

    static let TokenUrl = URL(string: "http://api.zapic.com/v1/game-center/token")

    static func getToken(signature: String, completion: @escaping ([String:Any]) -> Void) {

        var request = URLRequest(url: TokenUrl!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = signature.data(using: .utf8)

        let session = URLSession.shared

        let task = session.dataTask(with:request, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
            }

            if let response = response as? HTTPURLResponse {
                print("url = \(response.url!)")
                print("response = \(response)")
                print("response code = \(response.statusCode)")

                if response.statusCode == 200 {
                    if let body = deserialize(bodyData: data!) {
                        completion(body)
                        //                    if let resultStr = String(data: data!, encoding: .utf8){
                        //                        completion(resultStr)
                    }
                }
            }
        })

        //Run the task
        task.resume()
    }

    private static func deserialize(bodyData: Data) -> [String:Any]? {
        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
            let payload = json as? [String: Any] else {
                return nil
        }
        return payload
    }
}
