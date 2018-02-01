//
//  MessageManager.swift
//  Zapic
//
//  Created by Daniel Sarfati on 1/31/18.
//  Copyright © 2018 zapic. All rights reserved.
//

import Foundation

extension ZapicViewController: MessageController {

  func onAppReady() {
    resendFailedEvents()
    submitEvent(eventType: .appStarted, params: ["version": appVersion])
  }

  func send(type: WebFunction, payload: Any) {
    send(type: type, payload: payload, isError: false)
  }

  func send(type: WebFunction, payload: Any, isError: Bool) {

    //Ensure setSignature is the only method that can be sent before
    //the app is ready
    if !(status == .appReady || status == .pageReady) && type != .setSignature {
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

    webView.evaluateJavaScript(js) { (result, error) in
      if let error = error {
        ZLog.error("JS Error \(error)")
      } else if let result = result {
        ZLog.info("JS Result \(result)")
      }
    }
  }

  func submitEvent(eventType: EventType, params: [String: Any]) {

    if !(status == .appReady || status == .pageReady) {
      ZLog.info("Web client is not ready to accept events")
      return
    }

    ZLog.info("Submitting event to web client")

    let msg: [String: Any] = ["type": eventType.rawValue,
                              "params": params,
                              "timestamp": Date().iso8601]

    send(type: .submitEvent, payload: msg)
  }

  /// Attempt to resend all events that we unable to send
  func resendFailedEvents() {
    ZLog.info("Started resending \(eventQueue.count) events")

    while eventQueue.count > 0 {

      guard let event = eventQueue.dequeue() else {
        ZLog.warn("Resending invalid event")
        break
      }

      send(type: event.type, payload: event.payload, isError: event.isError)
    }

    ZLog.info("Finished resending events")
  }
}
