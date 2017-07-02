//
//  Swift.swift
//  ZapicSDKiOS
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

@objc(Zapic)
public class Zapic: NSObject{
    
    private static let tokenManager = TokenManager()
    
    public static func connect(){
        print("Zapic initializing...")
        
        if(tokenManager.hasValidToken()){
            print("Welcome back to Zapic")
            //TODO Show Zapic notification menu
        }
        else{
            GameCenterHelper.generateSignature(completion: {(signature:String) in
                print(signature)
                
                ApiClient.GetToken(signature:signature, completion: {(token:String) in
                    print("Received token: \(token)")
                    
                    tokenManager.updateToken(newToken: token)
                })
            })
        }
    }
}
