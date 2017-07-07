//
//  Swift.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import NotificationBannerSwift

@objc(Zapic)
public class Zapic: NSObject{
    
    private static let tokenManager = TokenManager(bundleId: Bundle.main.bundleIdentifier!)
    private static let zapicView = ZapicView()
    private static var hasConnected = false
    
    public static func connect(){
        
        if(hasConnected){
            print("Zapic already connected")
            return
        }
        
        hasConnected = true
        
        print("Zapic initializing...")
        
        if(tokenManager.hasValidToken()){
            
            print("Welcome back to Zapic")
            print("Using token \(tokenManager.token)")
            
            self.showBanner()
        }
        else{
            GameCenterHelper.generateSignature(completion: {(signature:String) in
                print(signature)
                
                ApiClient.GetToken(signature:signature, completion: {(body:[String:Any]) in
                    
                    print("Received token: \(body)")
                    
                    if let token = body["Token"] as? String{
                        tokenManager.updateToken(newToken: token )
                    }
                })
            })
        }
    }
    
    static func showBanner(){
        let banner = NotificationBanner(title: "Welcome back!", style: .success)
        banner.show()
    }
}
