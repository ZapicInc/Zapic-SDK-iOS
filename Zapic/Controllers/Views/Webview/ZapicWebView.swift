//
//  ZapicWebView.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/10/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import WebKit

// Events sent from the web client to the SDK
enum WebEvent: String {
  case login = "LOGIN"
  case appStarted = "APP_STARTED"
  case showBanner = "SHOW_BANNER"
  case showPage = "SHOW_PAGE"
  case showShare = "SHOW_SHARE_MENU"
  case pageReady = "PAGE_READY"
  case closePageRequest = "CLOSE_PAGE_REQUESTED"
  case loggedIn = "LOGGED_IN"
  case loggedOut = "LOGGED_OUT"
}

// Events sent from the SDK to the web client
enum WebFunction: String {
  case setSignature = "LOGIN_WITH_GAME_CENTER"
  case submitEvent = "SUBMIT_EVENT"
  case openPage = "OPEN_PAGE"
  case closePage = "CLOSE_PAGE"
  case setContacts = "SET_CONTACTS"
  case handleData = "HANDLE_DATA"
}

struct Event {
  let type: WebFunction
  let payload: Any
  let isError: Bool

  init(type: WebFunction, payload: Any, isError: Bool) {
    self.type = type
    self.payload = payload
    self.isError = isError
  }
}

protocol ZapicViewControllerDelegate: class {
  func onAppError(error: Error)
  func closePage()
  /**
   Opens the given link in a safari view
 **/
  func openLink(url: URL)
}

enum WebClientStatus {
  case none
  case loading
  case appReady
  case pageReady
  case error
}

internal class ZapicWebView: WKWebView, UIScrollViewDelegate {

  // Current retry attempt number. Resets when load is sucessful
  private var retryAttempt = 0

  private var loadSuccessful = false

  private var urlRequest: URLRequest?

  private var appUrl: String?

  private let events: [String] = ["dispatch", "console"]

  private let contentController = WKUserContentController()

  var controllerDelegate: ZapicViewControllerDelegate?

  var scriptMessageHandler: WKScriptMessageHandler? {
    didSet {
      if let newHandler = scriptMessageHandler {
        for event in events {
          contentController.add(newHandler, name: event)
        }
      }
    }
  }

  init() {
    let config = WKWebViewConfiguration()
    config.userContentController = contentController

    let injected = injectedScript(ios: UIDevice.current.systemVersion)

    let userScript = WKUserScript(source: injected, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    contentController.addUserScript(userScript)

    super.init(frame: .zero, configuration: config)

    self.navigationDelegate = self
    self.scrollView.delegate = self
    self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
  }

  // Disable zooming in webView
  func viewForZooming(scroll: UIScrollView) -> UIView? {
    return nil
  }

  override var safeAreaInsets: UIEdgeInsets {
    //Dont add any additional padding on non X
    if !UIDevice.current.iPhoneX {
      return UIEdgeInsets.zero
    }

    switch UIDevice.current.orientation {
    //Add extra padding on the top to avoid the notch
    case .portrait:
      return UIEdgeInsets(top: 34, left: 0, bottom: 21, right: 0)
    case .landscapeLeft, .landscapeRight:
      return UIEdgeInsets(top: 0, left: 44.0, bottom: 21, right: 44.0)
    default:
      return UIEdgeInsets.zero
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// Loads the given url. If no url specified, try the latest url
  ///
  /// - Parameter url: The url to load
  func load(_ appUrl: String? = nil) {

    if let newUrl = appUrl {
      guard let url = URL(string: newUrl) else {
        ZLog.error("Invalid URL: \(newUrl). Unable to load web application")
        return
      }
      urlRequest = URLRequest(url: url, timeoutInterval: 30)
    }

    self.appUrl = appUrl

    guard let appRequest = urlRequest else {
      ZLog.error("Invalid URL Request. Ensure a valid URL was set prior to a retry")
      return
    }

    ZLog.info("Loading web application from \(appRequest.url?.absoluteString ?? "unknown")")

    self.load(appRequest)
  }

  private func retryAfterDelay() {

    //Dont retry if the load has been successful
    if loadSuccessful {
      return
    }

    let base: Double = 5

    //Max delay (s)
    let maxDelay: Double = 20 * 60

    retryAttempt += 1

    let delay = max(1, drand48() * min(maxDelay, base * pow(2.0, Double(retryAttempt))))

    ZLog.info("Retrying load in \(delay) sec")

    //Attempt to load the web client again after a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      self.load()
    }
  }
}

extension ZapicWebView: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    ZLog.info("Finished loading webview content")
    retryAttempt = 0
    loadSuccessful = true
  }

  /// Handle errors loading web application
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {

    let error = error as NSError
    if error.domain == "WebKitErrorDomain" && error.code == 102 {
      ZLog.info("Skipping known error message loading a url")
      return
    }

    ZLog.warn("Error loading Zapic webview")

    retryAfterDelay()

    controllerDelegate?.onAppError(error: error)
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

    guard let url = navigationAction.request.url else {
      decisionHandler(.cancel)
      return
    }

    guard let rootUrl = appUrl else {
      decisionHandler(.cancel)
      return
    }

    //Allow the webview to open other links that are within our web app.
    if url.absoluteString.starts(with: rootUrl) {
      decisionHandler(.allow)
      return
    }

    //Gets the scheme (http, https, itms-*, ...)
    guard let scheme = navigationAction.request.url?.scheme else {
      decisionHandler(.cancel)
      return
    }

    //Allow the OS to open the itms links directly into the app store
    if scheme.starts(with: "itms") {
      UIApplication.shared.openURL(navigationAction.request.url!)
      decisionHandler(.cancel)
      return
    }

    //Show the link in a safari window
    controllerDelegate?.openLink(url: url)

    //Tell the webview not to open the link
    decisionHandler(.cancel)
  }
}
