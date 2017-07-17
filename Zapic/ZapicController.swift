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
import RxCocoa

class ZapicController: UIViewController {
    
    let webView: ZapicWebView
    let loading:LoadingView
    let offline:OfflineView
    let bag = DisposeBag()
    let viewModel: ZapicViewModel
    
    private var closeSub: Disposable?
    
    init(_ viewModel: ZapicViewModel){
        self.viewModel = viewModel
        webView = ZapicWebView(viewModel)
        loading = LoadingView(viewModel)
        offline = OfflineView(viewModel)
        
        super.init(nibName:nil, bundle:nil)
        
        bindToViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindToViewModel(){
        
        //Close window event
        viewModel.close.subscribe(onNext:{
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(bag)
        
        //App status event
        viewModel.viewStream.subscribe(onNext: { view in
            switch view {
            case .loading:
                self.view = self.loading
//                webView.load()
            case .offline:
                self.view = self.offline
            case .webView:
                self.view = self.webView
            }

        }).addDisposableTo(bag)
    }
    
    override func viewDidLoad() {
        print("Zapic viewDidLoad")
        view = loading
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Zapic viewWillAppear")
        view = loading
        webView.load()
    }
    
//    func bindView(_ view:ZapicView){
//        
//        //Connect to the close button
//        view.closeButton.rx.tap.subscribe(onNext: {
//            self.viewModel.closeWindow()
//        }).addDisposableTo(bag)
//    }
//    
//    func bindWebView(_ view:ZapicWebView) {
//        view.appStatus.subscribe(onNext: { status in
//            self.viewModel.setStatus(status: status)
//        }).addDisposableTo(bag)
//    }
    
//    override func viewWillAppear(_ animated: Bool) {
    
        //        //If the web view is already loaded, show it
        //        if webView.isReady {
        //            showView(webView)
        //        } else {
        //            webView.load()
        //            //Show the loading view
        //            showView(loading)
        //        }
//    }
    
    override func loadView() {
//        showView(.loading)
//        view = loading
        //
        //        //Wait for the webview to load, then show it
        //        self.webView.appLoaded.filter {$0 == WebViewStatus.loaded}.subscribe(onNext: {_ in
        //            self.showView(self.webView)
        //            }).addDisposableTo(bag)
        //
        //        //If the webview fails to load, show the offline menu
        //        self.webView.appLoaded.filter {$0 == WebViewStatus.offline}.subscribe(onNext: {_ in
        //             self.showView(self.offline)
        //            }).addDisposableTo(bag)
    }
    
//    private func showView(_ status:WebViewStatus){
//        switch status {
//        case .loading:
//            self.view = loading
//             webView.load()
//        case .offline:
//            self.view = offline
//        case .ready:
//            self.view = webView
//        }
//    }
//    
//    private func showView(_ view: UIView) {
//        
//        //Close any previous subscriptions
//        if let closeSub = closeSub {
//            closeSub.dispose()
//            self.closeSub = nil
//        }
//        
//        //        if let zapicView = view as? ZapicView {
//        //            self.closeSub = zapicView.closeSub.subscribe(onNext: {_ in
//        //                //Close this view controller
//        //                self.dismiss(animated: true, completion: nil)
//        //            })
//        //        }
//        
//        self.view = view
//    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        //Reset the view to the loading screen
//        self.showView(self.loading)
//    }
}
