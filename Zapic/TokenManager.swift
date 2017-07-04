//
//  TokenManager.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

class ZapicKey{
    static let Token = "ZAPIC_TOKEN"
}

class TokenManager {
    
    private(set) var token = ""
    
    init() {
        self.loadToken()
    }
    
    private func loadToken() {
        if let loadedToken = UserDefaults.standard.string(forKey: ZapicKey.Token){
            token = loadedToken
        }
    }
    
    func hasValidToken() -> Bool {
        return !token.isEmpty;
    }
    
    func updateToken(newToken:String) {
        print("Saving Zapic token")
        UserDefaults.standard.setValue(newToken, forKey: ZapicKey.Token)
        token = newToken
    }
}
