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
import SafariServices

internal class ZapicViewController: UIViewController, ZapicViewControllerDelegate, SFSafariViewControllerDelegate {

  /**
   Opens a link in an embedded safari view
   **/
  func openLink(url: URL) {
    let svc = SFSafariViewController(url: url, entersReaderIfAvailable: true)
    svc.delegate = self
    self.present(svc, animated: true, completion: nil)
  }

  /**
   Callback when the embedded safari view is complete
  **/
  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true, completion: nil)
  }

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

  var player: ZapicPlayer?

  /// Callback when the player has logged into Zapic.
  var onLoginHandler: ((ZapicPlayer) -> Void)?

  /// Callback when the player has logged out of Zapic.
  var onLogoutHandler: ((ZapicPlayer) -> Void)?

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

  func handleData(_ dataIn: String?) {
    guard let data = dataIn else {
      return
    }

    self.send(type: .handleData, payload: data)
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

  /**
   Shows the Zapic UIView
   */
  func onShowPage() {
    show(.current)
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

    guard let playerId = msg["userId"] as? String else {
      ZLog.warn("Invalid/missing value for userId, must be a string")
      return
    }

    guard let notificationToken = msg["notificationToken"] as? String else {
      ZLog.warn("Invalid/missing value for notification token, must be a string")
      return
    }

    //If there is an existing player, log out
    if self.player != nil {
      self.onLogoutHandler?(self.player!)
    }

    self.player = ZapicPlayer(playerId, notificationToken: notificationToken)
    self.onLoginHandler?(player!)
  }

  internal func decode(base64: String?) -> UIImage? {

    guard let string = base64 else {
      return nil
    }

    if let dataDecoded = Data(base64Encoded: string, options: NSData.Base64DecodingOptions(rawValue: 0)) {
      return UIImage(data: dataDecoded)
    } else {
      ZLog.warn("Invalid base64 string")
      return nil
    }
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
