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
    
    let viewStatus = PublishSubject<ViewStatus>()
    
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
        viewStatus.onNext(.close)
        viewStream.onNext(.loading)
    }
    
    func openWindow(){
        print("Zapic window opening")
        viewStatus.onNext(.open)
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
            if let reqSecret = event.payload as? UInt32,
                reqSecret == self.webSecret {
                
                jsCommands.onNext(WebFunction(function: "login(\(webSecret),'\(tokenManager.token)')"))
                jsCommands.onNext(WebFunction(function: "open(\(webSecret),'default')"))
            }
            else{
                print("Error processing onPageReady")
            }
        case "onPageReady":
            if let reqSecret = event.payload as? UInt32,
                reqSecret == self.webSecret {
                viewStream.onNext(.webView)
            }
            else{
                print("Error processing onPageReady")
            }
        case "onPageClosing":
            if let reqSecret = event.payload as? UInt32,
                reqSecret == self.webSecret {
                
                //TODO: Change this to event.payload[1] when this works
                let callbackId = 1
                viewStatus.onNext(.close)
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

struct WebEvent{
    
    let type:String
    let payload:Any
    
    init(type:String,payload:Any){
        self.type = type
        self.payload = payload
    }
}

struct WebFunction{
    
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

enum ViewStatus{
    case open
    case close
}

enum CurrentView {
    case loading
    case offline
    case webView
}

