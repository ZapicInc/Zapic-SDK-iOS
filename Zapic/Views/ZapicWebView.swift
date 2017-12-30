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
  //case appLoaded = "APP_LOADED"
  case appStarted = "APP_STARTED"
  case showBanner = "SHOW_BANNER"
  case pageReady = "PAGE_READY"
  case closePageRequest = "CLOSE_PAGE_REQUESTED"
  case getContacts = "GET_CONTACTS"
  case loggedIn = "LOGGED_IN"
}

// Events sent from the SDK to the web client
enum WebFunction: String {
  case setSignature = "LOGIN_WITH_GAME_CENTER"
  case submitEvent = "SUBMIT_EVENT"
  case openPage = "OPEN_PAGE"
  case closePage = "CLOSE_PAGE"
  case setContacts = "SET_CONTACTS"
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

protocol ZapicViewControllerDelegate : class {
  func onPageReady()
  func onAppError(error: Error)
  func closePage()
}

enum WebClientStatus {
  case none
  case loading
  case ready
  case error
}

class ZapicWebView: WKWebView, WKScriptMessageHandler, UIScrollViewDelegate, ZapicWebClient {

  private let appUrl: String = ZapicUtils.appUrl()

  private let events: [String]

  private var eventQueue = Queue<Event>()

  private (set) var isPageReady = false

  private(set) var status = WebClientStatus.none

  weak var zapicDelegate: ZapicDelegate?

  weak var controllerDelegate: ZapicViewControllerDelegate?

  init() {

    ZLog.info("Loading webclient from \(appUrl)")

    let config = WKWebViewConfiguration()
    let controller = WKUserContentController()
    config.userContentController = controller

    events = ["dispatch", "console"]

    let userScript = WKUserScript(source: injectedScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
    controller.addUserScript(userScript)

    super.init(frame: .zero, configuration: config)

    super.navigationDelegate = self
    super.scrollView.delegate = self

    for event in events {
      controller.add(self, name: event)
    }
  }

  // Disable zooming in webView
  func viewForZooming(scroll: UIScrollView) -> UIView? {
    return nil
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func load() {

    if status == .ready {
      ZLog.info("Web application is already ready")
      return
    }

    if status == .loading {
      ZLog.info("Web application is already loading")
      return
    }

    ZLog.info("Loading Zapic web application")

    status = .loading

    guard let myURL = URL(string: appUrl) else {
      ZLog.error("Invalid URL for web application")
      return
    }

    super.load(URLRequest(url: myURL, timeoutInterval:30))
  }

  func onAppError(error: Error) {
    status = .error
    controllerDelegate?.onAppError(error:error)
    zapicDelegate?.onAppError(error: error)
  }

  /// Receive messages from JS code
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

    let methodName = message.name

    switch methodName {
    case "dispatch":
      handleDispatch(message)
      break
    case "console":
      handleConsole(message)
    default:
      ZLog.warn("Received a message to unknown method: \(methodName)")
    }
  }

  private func handleConsole(_ message: WKScriptMessage) {

    guard let json = message.body as? [String: Any] else {
      ZLog.warn("Received invalid message format")
      return
    }

    guard let levelStr = json["level"] as? String else {
      ZLog.warn("Received invalid console message")
      return
    }

    guard let message = json["message"] as? [String] else {
      ZLog.warn("Received invalid console message")
      return
    }

    var level = ZLogLevel.info

    switch levelStr.uppercased() {
    case "ERROR":
      level = ZLogLevel.error
    case "WARN":
      level = ZLogLevel.warn
    case "INFO":
      fallthrough
    default:
      level = ZLogLevel.info
    }

    let text = message[0]
    let args = Array(message[2...])

    let msg = text.replaceSubstrings(string: "%s", args: args)

    ZLog.log(msg, level: level, source: .web)
  }

  private func handleDispatch(_ message: WKScriptMessage) {

    guard let json = message.body as? [String: Any] else {
      ZLog.warn("Received invalid message format")
      return
    }

    guard let typeValue = json["type"] as? String else {
      ZLog.warn("Received message with missing message type")
      return
    }

    guard let type = WebEvent(rawValue: typeValue) else {
      ZLog.warn("Received unknown message type \(typeValue)")
      return
    }

    ZLog.info("Received from JS: \(type) ")

    switch type {
    case .login:
      zapicDelegate?.getVerificationSignature()
      break
    case .getContacts:
      zapicDelegate?.getContacts()
      break
    case .appStarted:
      status = .ready
      zapicDelegate?.onAppReady()
      break
    case .loggedIn:
      loggedIn(json)
      break
    case .pageReady:
      isPageReady = true
      controllerDelegate?.onPageReady()
      break
    case .showBanner:
      receiveBanner(json)
      break
    case .closePageRequest:
      controllerDelegate?.closePage()
      break
    default:
      ZLog.warn("Unhandled message type \(type)")
      break
    }
  }

  private func decode(base64: String?) -> UIImage? {

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

  // MARK: - Receive Messages

  private func receiveBanner(_ json: [String:Any]) {
    guard let msg = json["payload"] as? [String:Any] else {
      ZLog.warn("Received invalid ShowBanner payload")
      return
    }

    guard let title = msg["title"] as? String else {
      ZLog.warn("ShowBanner title is required")
      return
    }

    let icon: UIImage? = decode(base64:msg["icon"] as? String)

    let subTitle = msg["subtitle"] as? String

    zapicDelegate?.showBanner(title: title, subTitle: subTitle, icon: icon)
  }

  private func loggedIn(_ json: [String: Any]) {

    guard let msg = json["payload"] as? [String:Any] else {
      ZLog.warn("Received invalid SetPlayerId payload")
      return
    }

    guard let playerIdString = msg["userId"] as? String else {
      ZLog.warn("Invalid/missing value for userId, must be a string")
      return
    }

    guard let playerId = playerIdString.asUUID() else {
      ZLog.warn("Could not convert userId to a valid UUID")
      return
    }

    zapicDelegate?.setPlayerId(playerId: playerId)
  }

  // MARK: - Events

  func dispatchToJS(type: WebFunction, payload:Any) {
    dispatchToJS(type: type, payload: payload, isError: false)
  }

  func dispatchToJS(type: WebFunction, payload:Any, isError: Bool) {

    //Ensure setSignature is the only method that can be sent before
    //the app is ready
    if status != .ready && type != .setSignature {
      ZLog.info("Web client is not ready to run JS. Adding to queue")

      eventQueue.enqueue(Event(type: type, payload: payload, isError: isError))
      return
    }

    ZLog.info("Dispatching JS event \(type.rawValue)")

    var msg = ["type": type.rawValue, "payload": payload]

    if isError {
      msg["error"]=true
    }

    guard let json = ZapicUtils.serialize(data: msg) else {
      return
    }

    let js = "zapic.dispatch(\(json))"

    ZLog.info("Dispatching \(js)")

    super.evaluateJavaScript(js) { (result, error) in
      if let error = error {
        ZLog.error("JS Error \(error)")
      } else if let result = result {
        ZLog.info("JS Result \(result)")
      }
    }
  }

  func submitEvent(eventType: EventType, params: [String:Any]) {

    if status != .ready {
      ZLog.info("Web client is not ready to accept events")
      return
    }

    ZLog.info("Submitting event to web client")

    let msg: [String:Any] = ["type": eventType.rawValue,
                             "params": params,
                             "timestamp": Date().iso8601]

    dispatchToJS(type:.submitEvent, payload: msg)
  }

  /// Attempt to resend all events that we unable to send
  func resendFailedEvents() {
    ZLog.info("Started resending \(eventQueue.count) events")

    while eventQueue.count > 0 {

      guard let event = eventQueue.dequeue() else {
        ZLog.warn("Resending invalid event")
        break
      }

      dispatchToJS(type: event.type, payload: event.payload, isError: event.isError)
    }

    ZLog.info("Finished resending events")

  }
}

extension ZapicWebView: WKNavigationDelegate {

  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    ZLog.info("Finished loading webview content")
  }

  /// Handle errors loading web application
  func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    ZLog.warn("Error loading Zapic webview")
    self.onAppError(error: error)
  }

  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    guard let scheme = navigationAction.request.url?.scheme else {
      decisionHandler(.cancel)
      return
    }

    if scheme.starts(with: "itms") {
      UIApplication.shared.openURL(navigationAction.request.url!)
      decisionHandler(.cancel)
      return
    }

     decisionHandler(.allow)
  }
}
