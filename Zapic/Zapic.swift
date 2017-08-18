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
  case invalidPlayer
  case invalidAuthSignature
}

enum ZapicEvents: String {
  case appStarted = "APP_STARTED"
}

@objc(Zapic)
public class Zapic: NSObject {

  private static let core = ZapicCore()

  public static func start(_ version: String) {
    core.start(version: version)
  }

  public static func submitEvent(eventId: String, value: Int) {
    core.submitEvent(eventId: eventId, value: value)
  }

  public static func submitEvent(eventId: String) {
    core.submitEvent(eventId: eventId, value: nil)
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
