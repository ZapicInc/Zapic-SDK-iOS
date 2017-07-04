//
//  Swift.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
//import NotificationBannerSwift

@objc(Zapic)
public class Zapic: NSObject{
    
    private static let tokenManager = TokenManager()
    private static let zapicView = ZapicView()
    
    public static func connect(){
        print("Zapic initializing...")
        
//        let banner = NotificationBanner(title: "Welcome", subtitle: "Subtitle", style: .success)
//        banner.show()
        
        if(tokenManager.hasValidToken()){
            print("Welcome back to Zapic")
            //TODO Show Zapic notification menu
            
            zapicView.setToken(token: tokenManager.token)
            zapicView.show()

        }
        else{
            GameCenterHelper.generateSignature(completion: {(signature:String) in
                print(signature)
                
                ApiClient.GetToken(signature:signature, completion: {(token:String) in
                    print("Received token: \(token)")
                    
                    tokenManager.updateToken(newToken: token)
                    
                    zapicView.setToken(token: token)
                    zapicView.show()

                })
            })
        }
    }
}
