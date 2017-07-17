//
//  ZapicViewModel.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/15/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation
import RxSwift

class WebEvent{
    
    let type:String
    let payload:Any
    
    init(type:String,payload:Any){
        self.type = type
        self.payload = payload
    }
}

enum WebViewStatus {
    case loading
    case ready
    case error
}

enum CurrentView {
    case loading
    case offline
    case webView
}

class ZapicViewModel{
    
    let close = PublishSubject<Void>()
    
    /**
     The current view that should be displayed
    */
    let viewStream = PublishSubject<CurrentView>()
    
    /**
     Events that should be set to a JS client
     */
    let jsCommands = PublishSubject<WebEvent>()
    
    let tokenManager:TokenManager
    
    init(tokenManager:TokenManager){
        self.tokenManager = tokenManager
    }
    
    func closeWindow(){
        print("Zapic window closing")
        close.onNext()
        viewStream.onNext(.loading)
    }
    
    func setStatus(status:WebViewStatus){
        print("Zapic app status \(status)")
        
        switch status {
        case .ready:
            viewStream.onNext(.loading)
        case .error:
            viewStream.onNext(.offline)
        default:
            viewStream.onNext(.loading)
        }
    }
    
    func receiveEvent(_ event: WebEvent){
        print("Received \(event.type) event")
        
        switch event.type {
        case "onAppReady":
            jsCommands.onNext(WebEvent(type: "setAuthToken", payload: tokenManager.token))
            jsCommands.onNext(WebEvent(type: "openPage", payload: "/profile"))
        case "onPageReady":
            viewStream.onNext(.webView)
        default:break
        }
    }
}
