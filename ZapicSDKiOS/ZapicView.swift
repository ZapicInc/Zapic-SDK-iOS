//
//  ZapicPanel.swift
//  ZapicSDKiOS
//
//  Created by Daniel Sarfati on 7/3/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import UIKit
import WebKit

import UIKit
import WebKit
class ZapicView: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    init(){
        super.init(nibName:nil, bundle:nil)
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        print("Zapic loadView")
        webView.uiDelegate = self
        view = webView

    }
    override func viewDidLoad() {
        print("Zapic viewDidLoad")
        super.viewDidLoad()
        
        let myURL = URL(string: "https://www.zapic.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    func show(){
        print("Zapic show")
        
         UIApplication.shared.keyWindow?.rootViewController?.present(self, animated: true, completion: nil)
    }
    
    func setToken(token:String){
        webView.evaluateJavaScript("setToken('\(token)')")
    }
}
