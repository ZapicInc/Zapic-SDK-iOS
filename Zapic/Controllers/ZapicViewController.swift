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
import Contacts

internal class ZapicViewController: UIViewController, ZapicViewControllerDelegate {

  ///Queue of gameplay events
  internal var eventQueue = Queue<Event>()

  ///The currently queued Open Page event
  internal var queuedPageEvent: Event?

  let contactStore = CNContactStore()
  let webView: ZapicWebView
  private let loading: LoadingView
  private let offline: OfflineView
  private let mainController: UIViewController
  let appVersion: String
  internal var status = WebClientStatus.none

  var playerId: String = ""

  convenience init() {
    self.init(webView: ZapicWebView())
  }

  init(webView: ZapicWebView) {
    self.webView = webView
    loading = LoadingView()
    offline = OfflineView()

    if let ctrl = UIApplication.shared.delegate?.window??.rootViewController {
      mainController = ctrl
    } else {
      fatalError("RootViewController not found, ensure this is called at the correct time")
    }

    //Get the version and build number from the bundle
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ,
      let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
      appVersion = "\(version):\(build)"
    } else {
      appVersion = "unknown"
    }

    super.init(nibName: nil, bundle: nil)

    //Subscribe to events from web app
    webView.scriptMessageHandler = self

    loading.controllerDelegate = self
    offline.controllerDelegate = self
    webView.controllerDelegate = self

    //Trick to keep the webview up and running
    mainController.view.addSubview(self.webView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func start() {

    if status != .none {
      ZLog.warn("Zapic already started. Start should only be called once.")
      return
    }

    ZLog.info("Zapic starting. App version \(appVersion)")

    loadWebApp()

    submitEvent(eventType: .appStarted, params: ["version": appVersion])
  }

  private func loadWebApp() {
    if status == .appReady || status == .pageReady {
      ZLog.info("Web application is already ready")
      return
    }

    if status == .loading {
      ZLog.info("Web application is already loading")
      return
    }

    status = .loading

    let appUrl: String = ZapicUtils.appUrl()

    webView.load(appUrl)
  }

  func show(_ zapicView: ZapicViews) {

    ZLog.info("Show \(zapicView.rawValue)")

    if status == .pageReady {
      view = webView
    } else if status == .error {
      view = offline
    } else {
      //Reset the view to loading
      view = loading
    }

    //Trigger the web to update
    self.send(type: .openPage, payload: zapicView.rawValue)

    if view != webView {
      view.addSubview(self.webView)
    }

    //Show the ui
    self.mainController.present(self, animated: true, completion: nil)
  }

  func closePage() {
    super.dismiss(animated: true) {
      self.send(type: .closePage, payload: "")
      self.mainController.view.addSubview(self.webView)
    }
  }

  func onPageReady() {
    ZLog.info("Page is ready to be shown to the user")
    view = webView
  }

  func onAppError(error: Error) {
    view = offline
  }

  func loggedIn(_ json: [String: Any]) {

    guard let msg = json["payload"] as? [String: Any] else {
      ZLog.warn("Received invalid SetPlayerId payload")
      return
    }

    guard let userId = msg["userId"] as? String else {
      ZLog.warn("Invalid/missing value for userId, must be a string")
      return
    }

    self.playerId = userId
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
    if self.presentedViewController != nil {
      super.dismiss(animated: flag, completion: completion)
    }
  }
}
