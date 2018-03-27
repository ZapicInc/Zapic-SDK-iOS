//
//  Swift.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

public enum ZapicViews: String {
  case main
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

@objc(Zapic)
public class Zapic: NSObject {

  private static let controller = ZapicViewController()

  @objc public static var playerId: String? {
    return controller.playerId
  }

  @objc public static func start() {
    controller.start()
  }

  @objc public static func submitEvent(json: String) {
    guard let params = ZapicUtils.deserialize(json) else {
      ZLog.error("Unable to deserialize event from json data")
      return
    }

    controller.submitEvent(eventType: .gameplay, params: params)
  }

  @objc public static func submitEvent(_ params: [String: Any]) {
    controller.submitEvent(eventType: .gameplay, params: params)
  }

  @objc public static func show(viewName: String) {
    guard let view = ZapicViews(rawValue: viewName) else {
      ZLog.error("Invalid view name \(viewName)")
      return
    }
    show(view: view)
  }

  public static func show(view: ZapicViews) {
    controller.show(view)
  }
}
