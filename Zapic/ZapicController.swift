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
    
    private let webView: ZapicWebView
    private let loading:LoadingView
    private let offline:OfflineView
    private let bag = DisposeBag()
    private let viewModel: ZapicViewModel
    private let mainController: UIViewController
    
    private var closeSub: Disposable?
    
    init(_ viewModel: ZapicViewModel){
        self.viewModel = viewModel
        webView = ZapicWebView(viewModel)
        loading = LoadingView(viewModel)
        offline = OfflineView(viewModel)
        
        if let ctrl = UIApplication.shared.delegate?.window??.rootViewController {
            mainController = ctrl
        }
        else {
            fatalError("RootViewController not found, ensure")
        }

        
        super.init(nibName:nil, bundle:nil)
        
        bindToViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindToViewModel(){
        
        //Close window event
        viewModel.viewStatus.subscribe(onNext:{ status in
            
            if status == .open{
                 self.mainController.present(self, animated: true, completion: nil)
            }
            else{
                self.dismiss(animated: true, completion: nil)
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        print("Zapic viewWillAppear")
        view = loading
        webView.load()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
