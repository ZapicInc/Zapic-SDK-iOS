//
//  ZapicWebView.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/10/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import WebKit
import RxSwift

class ZapicWebView: WKWebView, WKScriptMessageHandler, WKNavigationDelegate {

    private let appUrl = "https://client.zapic.net"
    
    private let events: [String]
    
    private let viewModel:ZapicViewModel
    
    private var isReady: Bool = false
    
    private let bag = DisposeBag()
    
    init(_ viewModel:ZapicViewModel) {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        config.userContentController = controller
        
        self.viewModel = viewModel
        
        events = ["onAppReady",
                  "onPageReady"]
        
        super.init(frame: .zero, configuration: config)
        
        super.navigationDelegate = self
        
        for event in events {
            controller.add(self, name: event)
        }
        
        bindToViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindToViewModel(){
        viewModel.jsCommands.subscribe(onNext:{ event in
            self.dispatchToJS(event:event)
        }).addDisposableTo(bag)
    }
    
    func load() {
        print("Loading Zapic application")
        
        if let myURL = URL(string: appUrl) {
            super.load(URLRequest(url: myURL, timeoutInterval:30))
        }
        else{
            print("Error loading Zapic application")
            viewModel.setStatus(status: .error)
        }
    }
    
    /**
     Handle errors loading web application
    */
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("Error loading Zapic webview")
        viewModel.setStatus(status: .error)
    }
    
    /**
     Receive messages from JS code
     */
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        print("Received from JS: \(message.name), \(message.body) ")
        
        let event = WebEvent(type:message.name,payload:message.body)
        
        viewModel.receiveEvent(event)
    }
    
    private func dispatchToJS(event:WebEvent) {
        
        print("Dispatching JS event \(event.type)")
        
        if let payload = ZapicUtils.serialize(data: event.payload),
            let content = String(data: payload, encoding: String.Encoding.utf8) {
            
            let msg = "{'type':'\(event.type)','payload':'\(content)'}"
            
            super.evaluateJavaScript("zapicDispatch(\(msg))") { (result, error) in
                
                if let error = error {
                    print("JS Error \(error)")
                    self.viewModel.setStatus(status:.error)
                } else if let result = result {
                    print("JS Result \(result)")
                }
            }
        }
    }

    
//    private func dispatchToJS(_ event: String, payload data: Any) {
//
//        if let payload = ZapicUtils.serialize(data: data),
//            let content = String(data: payload, encoding: String.Encoding.utf8) {
//
//            let msg = "{'type':'\(event)','payload':'\(content)'}"
//
//            super.evaluateJavaScript("zapicDispatch(\(msg))") { (result, error) in
//
//                if let error = error {
//                    print("JS Error \(error)")
//                } else if let result = result {
//                    print("JS Result \(result)")
//                }
//            }
//        }
//    }
//
//    private func sendToken() {
//        dispatchToJS("setToken", payload: "ABC")//tokenManager.token)
//    }
//
//    private func onTokenRequest(data:Any) {
//        sendToken()
//    }
//
//    private func onAppReady(data:Any) {
//        isReady = true
//        viewModel.setStatus(status: .ready)
//    }
}
