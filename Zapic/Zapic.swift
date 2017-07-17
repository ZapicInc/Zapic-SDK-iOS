//
//  Swift.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import NotificationBanner
import RxSwift

@objc(Zapic)
public class Zapic: NSObject {
    
    private static let core = ZapicCore()
    
    public static func connect() {
        core.connect()
    }
    
    public static func showMainView() {
        core.showMainView()
    }
}

class ZapicCore{
    
    private let tokenManager: TokenManager
    private let viewModel: ZapicViewModel
    private let mainController: UIViewController
    private let zapicController: ZapicController
    private var hasConnected = false
    private let bag = DisposeBag()
    
    init(){
        
        if let ctrl = UIApplication.shared.delegate?.window??.rootViewController {
            mainController = ctrl
        }
        else {
            fatalError("RootViewController not found, ensure")
        }
        
        tokenManager = TokenManager(bundleId: Bundle.main.bundleIdentifier!)
        viewModel = ZapicViewModel(tokenManager: tokenManager)
        zapicController = ZapicController(viewModel)
    }
    
    func connect() {
        
        if hasConnected {
            print("Zapic already connected, skipping")
            return
        }
        
        hasConnected = true
        
        print("Zapic connecting...")
        
        if tokenManager.hasValidToken() {
            
            print("Welcome back to Zapic")
            print("Using token \(tokenManager.token)")
            
            self.showBanner()
            
        } else {
            GameCenterHelper.generateSignature()
                .flatMap {ApiClient.getToken(signature: $0)}
                .map {$0["Token"] as? String ?? ""}
                .subscribe(onNext: {
                    self.tokenManager.updateToken(newToken: $0)
                }, onError: { _ in
                    self.tokenManager.clearToken()
                })
                .addDisposableTo(bag)
        }
    }
    
    func showMainView() {
        print("Showing main Zapic window")
        
        mainController.present(zapicController, animated: true, completion: nil)
    }
    
    func showBanner() {
        let banner = NotificationBanner(customView: WelcomeBannerView())
        banner.show(on: mainController)
    }
}

//            self.dismiss(animated: true, completion: nil)
