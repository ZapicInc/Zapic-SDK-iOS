//
//  ZapicCore.swift
//  Zapic
//
//  Created by Daniel Sarfati on 8/18/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

class ZapicCore: ZapicDelegate {

  private var webClient: ZapicWebClient
  private let zapicController: ZapicController
  private let contactManager = ContactManager()
  private var hasStarted = false

  /// Current retry attempt number. Resets when load is sucessful
  private var retryAttempt = 0

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

  func getContacts() {
    contactManager.getContacts {contacts in

      if let contacts = contacts {
        self.webClient.dispatchToJS(type: .setContacts, payload: contacts)
      } else {
        self.webClient.dispatchToJS(type: .setContacts, payload: "Unable to get contacts", isError:true)
      }
    }
  }

  func submitEvent(eventId: String, value: Int? = nil) {
    //Guard against reserved app ids
    if ZapicEvents(rawValue: eventId) != nil {
      ZLog.error("Event id \(eventId) is reserved, please choose a new id")
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
