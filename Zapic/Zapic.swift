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
    private let apiClient:ApiClient
    private let zapicController: ZapicController
    private var hasConnected = false
    private var storage = UserDefaultsStorage()
    private let bag = DisposeBag()
    private let mainController: UIViewController
    
    init(){
        tokenManager = TokenManager(bundleId: Bundle.main.bundleIdentifier!,storage: storage)
        viewModel = ZapicViewModel(tokenManager: tokenManager)
        zapicController = ZapicController(viewModel)
        apiClient = ApiClient(tokenManager: tokenManager)
        
        if let ctrl = UIApplication.shared.delegate?.window??.rootViewController {
            mainController = ctrl
        }
        else {
            fatalError("RootViewController not found, ensure")
        }
    }
    
    func connect() {
        
        if hasConnected {
            print("Zapic already connected, skipping")
            return
        }
        
        hasConnected = true
        
        print("Zapic connecting")
        
        //Debug only. Turn this on to simulate the complete workflow
//        tokenManager.clearToken()
        
        if tokenManager.hasValidToken() {
            
            print("Welcome back to Zapic")
            print("Using token \(tokenManager.token)")
            
            self.showBanner()
            self.connected()
            
        } else {
            GameCenterHelper.generateSignature()
                .flatMap {self.apiClient.getToken(signature: $0)}
                .map {$0["Token"] as? String ?? ""}
                .subscribe(onNext: {
                    self.tokenManager.updateToken($0)
                    self.connected()
                }, onError: { _ in
                    self.tokenManager.clearToken()
                })
                .addDisposableTo(bag)
        }
    }
    
    private func connected(){
        print("Zapic connected")
        
       apiClient.sendActivity(Activity(.appStarted)).subscribe().addDisposableTo(bag)
    }
    
    func showMainView() {
        print("Showing main Zapic window")
        viewModel.openWindow()
    }
    
    func showBanner() {
        let banner = NotificationBanner(customView: WelcomeBannerView())
        banner.show(on: mainController)
    }
}
