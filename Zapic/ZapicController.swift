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

class ZapicController: UIViewController, ZapicViewControllerDelegate {

  let webView: ZapicWebView
  private let loading: LoadingView
  private let offline: OfflineView
  private let mainController: UIViewController

  init() {
    webView = ZapicWebView()
    loading = LoadingView()
    offline = OfflineView()

    if let ctrl = UIApplication.shared.delegate?.window??.rootViewController {
      mainController = ctrl
    } else {
      fatalError("RootViewController not found, ensure this is called at the correct time")
    }

    super.init(nibName:nil, bundle:nil)

    loading.controllerDelegate = self
    offline.controllerDelegate = self
    webView.controllerDelegate = self

    //Trick to keep the webview up and running
    mainController.view.addSubview(self.webView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func show(view zapicView: ZapicViews) {

    if webView.isPageReady {
      view = webView
    } else if webView.status == .error {
      view = offline
    } else {
      //Reset the view to loading
      view = loading
    }

    //Trigger the web to update
    webView.dispatchToJS(type: .openPage, payload: zapicView.rawValue)

    //Show the ui
    self.mainController.present(self, animated: true, completion: nil)
  }

  func closePage() {
    self.dismiss(animated: true) {
      self.webView.dispatchToJS(type: .closePage, payload:"")
    }
  }

  func onPageReady() {
    ZLog.info("Page is ready to be shown to the user")
    view = webView
  }

  func onAppError(error: Error) {
    view = offline
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
