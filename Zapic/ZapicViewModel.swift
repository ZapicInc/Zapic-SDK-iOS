//
//  ZapicViewModel.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/15/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation
import RxSwift

class ZapicViewModel{
    
    let close = PublishSubject<Void>()
    
    var webSecret:UInt32 = 0
    
    /**
     The current view that should be displayed
    */
    let viewStream = PublishSubject<CurrentView>()
    
    /**
     Events that should be set to a JS client
     */
    let jsCommands = PublishSubject<WebFunction>()
    
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
        case "onAppLoaded":
            webSecret = arc4random_uniform(UInt32.max)
            jsCommands.onNext(WebFunction(function: "initialize(\(webSecret), 1)"))
        case "onAppReady":
            jsCommands.onNext(WebFunction(function: "login(\(webSecret),'\(tokenManager.token)')"))
            jsCommands.onNext(WebFunction(function: "open(\(webSecret),'default')"))
        case "onPageReady":
//            if let reqSecret = event.payload as? Int {
                viewStream.onNext(.webView)
//            }
        case "onPageClosing":
            if let callbackId = event.payload as? Int {
                close.onNext()
                jsCommands.onNext(WebFunction(function:"callback(\(webSecret), \(callbackId), true)"))
            }
        case "onPageClosed":
            //Do nothing
            print("Page closed")
        default:
            print("Unhandled event \(event.type)")
            break
        }
    }
}

class WebEvent{
    
    let type:String
    let payload:Any
    
    init(type:String,payload:Any){
        self.type = type
        self.payload = payload
    }
}

class WebFunction{
    
    let function:String
    
    init(function:String){
        self.function = function
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

