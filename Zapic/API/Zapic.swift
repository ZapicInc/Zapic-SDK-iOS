//
//  Swift.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

public enum ZapicPages: String {
  case profile
  case challenges
  case createChallenge
  case stats
}

enum ZapicError: Error {
  case unknownError
  case invalidCredentials
  case invalidPlayer
  case invalidAuthSignature
}

@objc public class ZapicPlayer: NSObject, Codable {
  /// The unique id for this player
  @objc public let playerId: String

  /// The push notification token used to id a player
  @objc public let notificationToken: String

  init(_ playerId: String, notificationToken: String!) {
    self.playerId = playerId
    self.notificationToken = notificationToken
  }
}

@objc(Zapic)
public class Zapic: NSObject {

  private static let controller = ZapicViewController()

  /// The tag key used to identity the notification token
  @objc public static let notificationTag: String = "zapic_player_token"

  /**
  The unique player, if authenticated
   */
  @objc public static var player: ZapicPlayer? {
    return controller.player
  }

  /**
   Callback when the player logs in
   */
  @objc public static var onLoginHandler: ((ZapicPlayer) -> Void)? {
    didSet {
        controller.onLoginHandler = onLoginHandler
    }
  }

  /**
   Callback when the player logs in
   */
  @objc
  public static var onLogoutHandler: ((ZapicPlayer) -> Void)? {
    didSet {
      controller.onLogoutHandler = onLogoutHandler
    }
  }

  @objc
  public static func start() {
    controller.start()
  }

  /**
   Handle Zapic data. Usually from an integration like push notifications.
   */
  @objc
  public static func handleInteraction(_ dict: [AnyHashable: Any]?) {
    if let val = dict?["zapic"] {
      controller.handleInteraction("\(val)")
    } else {
      ZLog.info("Skipping data, unable to find any 'zapic' data")
    }
  }

  /**
   Submit a gameplay event. These parameters should match those defined in
   the developer portal.
   */
  @objc
  public static func submitEvent(_ params: [String: Any]) {
    controller.submitEvent(eventType: .gameplay, params: params)
  }

  /**
   Show a Zapic view.
   */
  @objc
  public static func showPage(_ pageName: String) {
    controller.show(pageName)
  }

  /**
   Show a Zapic view.
   */
  public static func showPage(_ view: ZapicPages) {
    controller.show(view.rawValue)
  }

  /**
   Show the default Zapic view.
   */
  @objc
  public static func showDefaultPage() {
    controller.showDefault()
  }
}
