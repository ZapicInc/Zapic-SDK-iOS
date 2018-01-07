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

  /// Triggers retrieving all contacts from the device
  func getContacts()

  /// Trigger when the player id is received for the user
  func setPlayerId(playerId: UUID)
}
