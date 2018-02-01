//
//  ZapicDelegate.swift
//  Zapic
//
//  Created by Daniel Sarfati on 10/17/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

protocol ZapicDelegate: class {

  /// Triggers the generation of the
  /// Game Center verification signature
  func getVerificationSignature()

  /// Trigger when the web client is ready for
  /// the native client to call it
  func onAppReady()

  /// Trigger when the web client has an error
  func onAppError(error: Error)

  /// Trigger when a banner should be shown
  func showBanner(title: String, subTitle: String?, icon: UIImage?)

  /// Trigger when the player id is received for the user
  func setPlayerId(playerId: UUID)
}

protocol GameCenterController {
  /// Triggers the generation of the
  /// Game Center verification signature
  func getVerificationSignature()
}

protocol MessageController {

  /// Attempt to resend all events that we unable to be sent
  func resendFailedEvents()

  func submitEvent(eventType: EventType, params: [String: Any])

  func send(type: WebFunction, payload: Any)

  func send(type: WebFunction, payload: Any, isError: Bool)
}

protocol BannerController {
  func showBanner(title: String, subTitle: String?, icon: UIImage?)
}

protocol ContactsController {

  /// Retrieve all contacts from the device and send them
  func getContacts()
}
