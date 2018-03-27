//
//  WK.swift
//  Zapic
//
//  Created by Daniel Sarfati on 1/31/18.
//  Copyright © 2018 zapic. All rights reserved.
//

import Foundation
import WebKit

extension ZapicViewController: WKScriptMessageHandler {

  /// Receive messages from JS code
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

    let methodName = message.name

    switch methodName {
    case "dispatch":
      handleDispatch(message)
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

    handleMessage(type: type, json: json)
  }

  private func handleMessage(type: WebEvent, json: [String: Any]) {

    ZLog.info("Received from JS: \(type) ")

    switch type {
    case .login:
      self.getVerificationSignature()
    case .getContacts:
      getContacts()
    case .appStarted:
      status = .appReady
      onAppReady()
    case .loggedIn:
      loggedIn(json)
    case .pageReady:
      status = .pageReady
      onPageReady()
    case .showBanner:
      receiveBanner(json)
    case .closePageRequest:
      closePage()
    case .showShare:
      showShareMenu(json)
    }
  }
}
