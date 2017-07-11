//
//  ZapicPanel.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/3/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import RxSwift

class ZapicController: UIViewController {

    let webView: ZapicWebView
    let loading = LoadingView()
    let bag = DisposeBag()

    init(_ tokenManager: TokenManager) {
        webView = ZapicWebView(tokenManager:tokenManager)
        super.init(nibName:nil, bundle:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        //Show the loading view
        view = loading

        //Wait for the webview to load, then show it
        self.webView.appLoaded.filter {$0 == WebViewStatus.loaded}.subscribe {_ in
            self.view = self.webView
            }.addDisposableTo(bag)
        
        //If the webview fails to load, show the offline menu
        self.webView.appLoaded.filter {$0 == WebViewStatus.offline}.subscribe {_ in
            self.view = OfflineView()
            }.addDisposableTo(bag)
    }

    override func viewDidLoad() {
        //Create hidden WV
        webView.load()
    }
}
