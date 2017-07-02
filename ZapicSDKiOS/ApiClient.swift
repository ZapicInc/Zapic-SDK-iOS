//
//  ApiClient.swift
//  ZapicSDKiOS
//
//  Created by Daniel Sarfati on 7/1/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

class ApiClient{
    
    static let TOKEN_URL = URL(string: "https://functionapp20170627104002.azurewebsites.net/api/api/v1/game-center/token?code=TnpUHz3/pyRhQJZmrVaXsVHmW3Qaramk8dSaCZwmYojRRGOzdVG47g==")
    
    static func GetToken(signature:String, completion: @escaping (String) -> Void){
        
        var request = URLRequest(url: TOKEN_URL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField:"Content-Type")
        request.httpBody = signature.data(using: .utf8)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with:request, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
            }
            
            if let response = response {
                print("url = \(response.url!)")
                print("response = \(response)")
                let httpResponse = response as! HTTPURLResponse
                print("response code = \(httpResponse.statusCode)")
                
                if(httpResponse.statusCode == 200){
                    if let resultStr = String(data: data!, encoding: .utf8){
                        completion(resultStr)
                    }
                }
            }
        })
        
        //Run the task
        task.resume()
    }
}
