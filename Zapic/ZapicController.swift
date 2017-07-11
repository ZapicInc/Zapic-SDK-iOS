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
    
    private var closeSub:Disposable?;

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
        self.webView.appLoaded.filter {$0 == WebViewStatus.loaded}.subscribe(onNext:{_ in
            self.showView(view: self.webView)
            }).addDisposableTo(bag)

        //If the webview fails to load, show the offline menu
        self.webView.appLoaded.filter {$0 == WebViewStatus.offline}.subscribe(onNext:{_ in
             self.showView(view: OfflineView())
            }).addDisposableTo(bag)
    }
    
    private func showView(view:UIView){
        
        //Close any previous subscriptions
        if let closeSub = closeSub{
            closeSub.dispose()
            self.closeSub = nil
        }
        
        if let zapicView = view as? ZapicView{
            self.closeSub = zapicView.closeSub.subscribe(onNext:{_ in
                //Close this view controller
                self.dismiss(animated: true, completion: nil)
            })
        }
        
        self.view = view
    }

    override func viewDidLoad() {
        //Create hidden WV
        webView.load()
    }
}
