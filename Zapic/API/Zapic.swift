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
  //Open Zapic without changing the page
  case current
  case profile
  case challenges
}

enum ZapicError: Error {
  case unknownError
  case invalidCredentials
  case invalidPlayer
  case invalidAuthSignature
}

enum EventType: String {
  case unknown = "Unknown"
  case appStarted = "AppStarted"
  case gameplay = "Gameplay"
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
  public static func handleData(_ dict: [AnyHashable: Any]?) {
    if let val = dict?["zapic"] {
      controller.handleData("\(val)")
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
  public static func show(viewName: String) {
    guard let view = ZapicViews(rawValue: viewName) else {
      ZLog.error("Invalid view name \(viewName)")
      return
    }
    show(view: view)
  }

  /**
   Show a Zapic view.
   */
  public static func show(view: ZapicViews) {
    controller.show(view)
  }
}
