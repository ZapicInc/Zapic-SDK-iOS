//
//  Swift.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

public enum ZapicViews: String {
  case main = "default"
  case profile
  case achievements
}

enum ZapicError: Error {
  case unknownError
  case invalidCredentials
  case reservedEventId
  case invalidPlayer
  case invalidAuthSignature
  //    case connectionError
  //    case invalidRequest
  //    case notFound
  //    case invalidResponse
  //    case serverError
  //    case serverUnavailable
  //    case timeOut
  //    case unsuppotedURL
}

@objc(Zapic)
public class Zapic: NSObject {

  private static let core = ZapicCore()

  public static func start(_ version: String) {
    core.start(version: version)
  }

  public static func submitEvent(eventId: String, value: Int) throws {
    try core.submitEvent(eventId: eventId, value: value)
  }

  public static func submitEvent(eventId: String) throws {
    try core.submitEvent(eventId: eventId, value: nil)
  }

  public static func show(viewName: String) {
    guard let view = ZapicViews(rawValue: viewName) else {
      ZLog.error("Invalid view name \(viewName)")
      return
    }
    show(view:view)
  }

  public static func show(view: ZapicViews) {
    core.show(view: view)
  }
}

class ZapicCore: ZapicDelegate {

  private var webClient: ZapicWebClient
  private let zapicController: ZapicController
  private var hasStarted = false

  /// Current retry attempt number. Resets when load is sucessful
  private var retryAttempt = 0

  //  private var storage = UserDefaultsStorage()

  init() {
    if ZLog.isEnabled {
      ZLog.info("Logging is enabled. Disable via ZLog.isEnabled.")
    }

    zapicController = ZapicController()
    webClient = zapicController.webView
    webClient.zapicDelegate = self
  }

  init(webClient: ZapicWebClient) {
    zapicController = ZapicController()
    self.webClient = webClient
    self.webClient.zapicDelegate = self
  }

  func start(version: String) {
    if hasStarted {
      ZLog.warn("Zapic already started. Start should only be called once.")
      return
    }

    ZLog.info("Zapic starting. App version \(version)")

    hasStarted = true

    webClient.load()
  }

  func submitEvent(eventId: String, value: Int? = nil) throws {
    //Guard against reserved app ids
    if ZapicEvents(rawValue: eventId) != nil {
      throw ZapicError.reservedEventId
    }
    return submitEventUnchecked(eventId:eventId, value:value)
  }

  private func submitEventUnchecked(eventId: String, value: Int? = nil) {
    webClient.submitEvent(eventId: eventId, timestamp: Date(), value: value)
  }

  func show(view: ZapicViews) {
    ZLog.info("Show \(view.rawValue)")
    zapicController.show(view:view)
  }

  func getVerificationSignature() {
    ZLog.info("Getting verification signature")

    GameCenterHelper.generateSignature { (signature, _) in

      if let sig = signature {
        self.webClient.dispatchToJS(type: .setSignature, payload: sig)
      } else {
        self.webClient.dispatchToJS(type: .setSignature, payload: "Error with Game Center", isError:true)
      }
    }
  }

  /// Trigger when a banner should be shown
  func showBanner(title: String, subTitle: String?, icon: UIImage?) {

    let banner = Banner(title: title, subtitle:subTitle, icon:icon)

    banner.dismissesOnTap = true
    banner.show(duration: 3.0)
  }

  func onAppReady() {
    retryAttempt = 0
    webClient.resendFailedEvents()
    submitEventUnchecked(eventId: ZapicEvents.appStarted.rawValue)
  }

  func onAppError(error: Error) {
    let base: Double = 5
    //Max delay (s)
    let maxDelay: Double = 20 * 60

    retryAttempt += 1

    let delay = max(1, drand48() * min(maxDelay, base * pow(2.0, Double(retryAttempt))))

    ZLog.debug("Retrying load in \(delay) sec")

    //Attempt to load the web client again after a delay
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
      self.webClient.load()
    }
  }
}

enum ZapicEvents: String {
  case appStarted = "APP_STARTED"
}
