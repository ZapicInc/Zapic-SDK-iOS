//
//  Swift.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import NotificationBannerSwift
import RxSwift

@objc(Zapic)
public class Zapic: NSObject {

    private static let tokenManager = TokenManager(bundleId: Bundle.main.bundleIdentifier!)
    private static let zapicController = ZapicController(tokenManager)
    private static var hasConnected = false
    private static let disposeBag = DisposeBag()

    public static func connect() {

        if hasConnected {
            print("Zapic already connected")
            return
        }

        hasConnected = true

        print("Zapic initializing...")

        if tokenManager.hasValidToken() {

            print("Welcome back to Zapic")
            print("Using token \(tokenManager.token)")

            self.showBanner()

        } else {
            GameCenterHelper.generateSignature()
                .flatMap {ApiClient.getToken(signature: $0)}
                .map {$0["Token"] as? String ?? ""}
                .subscribe(onNext: {
                    tokenManager.updateToken(newToken: $0)
                }, onError: { _ in
                    tokenManager.clearToken()
                })
                .addDisposableTo(disposeBag)
        }
        showWebView()
    }

    static func showWebView() {
        print("Zapic show")

        UIApplication.shared.keyWindow?.rootViewController?.present(zapicController, animated: true, completion: nil)
    }

    static func showBanner() {

        let banner = NotificationBanner(customView: WelcomeBannerView())
        banner.show()
    }
}
