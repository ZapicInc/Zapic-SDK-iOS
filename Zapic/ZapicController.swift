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
    
    deinit {
        print("MyViewController deinit called")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Zapic viewWillAppear")
        view = loading
        webView.load()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
