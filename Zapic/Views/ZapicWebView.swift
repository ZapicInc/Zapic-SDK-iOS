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

enum WebViewStatus {
    case loading
    case loaded
    case offline
}

class ZapicWebView: WKWebView, WKScriptMessageHandler, WKNavigationDelegate {

    private var events: [String: (Any) -> Void] = [String: (Any) -> Void]()

    private let appUrl = "http://localhost:5000"
    private let tokenManager: TokenManager
    let appLoaded = BehaviorSubject<WebViewStatus>(value:.loading)

    init(tokenManager tManager: TokenManager) {
        let config = WKWebViewConfiguration()
        let controller = WKUserContentController()
        config.userContentController = controller

        tokenManager = tManager

        super.init(frame: .zero, configuration: config)
        
        super.navigationDelegate = self

        events["getToken"]=self.onTokenRequest(data:)
        events["appReady"]=self.onAppReady(data:)

        for event in events {
            controller.add(self, name: event.key)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load() {
        print("Loading Zapic application")
        if let myURL = URL(string: appUrl) {
            super.load(URLRequest(url: myURL, timeoutInterval:30))
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Received from JS: \(message.name), \(message.body) ")

        if let handler = events[message.name] {
            handler(message.body)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        appLoaded.onNext(.offline)
        appLoaded.onCompleted()
    }

    private func dispatchToJS(_ event: String, payload data: Any) {

        if let payload = ZapicUtils.serialize(data: data),
            let content = String(data: payload, encoding: String.Encoding.utf8) {

            let msg = "{'type':'\(event)','payload':'\(content)'}"

            super.evaluateJavaScript("zapicDispatch(\(msg))") { (result, error) in

                if let error = error {
                    print("JS Error \(error)")
                } else if let result = result {
                    print("JS Result \(result)")
                }
            }
        }
    }

    private func sendToken() {
        dispatchToJS("setToken", payload: tokenManager.token)
    }

    private func onTokenRequest(data:Any) {
        sendToken()
    }

    private func onAppReady(data:Any) {
        appLoaded.onNext(.loaded)
        appLoaded.onCompleted()
    }
}
