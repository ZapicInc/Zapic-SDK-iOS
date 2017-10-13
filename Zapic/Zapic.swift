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

enum EventType: String {
  case unknown = "Unknown"
  case appStarted = "AppStarted"
  case gameplay = "Gameplay"
}

//// public enum EventType
//{
//  Unknown,
//
//  /// <summary>Event when the app opens</summary>
//  AppStarted,
//
//  /// <summary>In game events, from the game developer.</summary>
//  Gameplay,
//}
//
///// <summary>Type of event.</summary>
//[JsonProperty("type", Order = 1)]
//[Required]
//public EventType? EventType { get; set; }
//
///// <summary>Collection of parameters [Key, Value]</summary>
//[JsonProperty("params", Order = 1)]
//[Required]
//public Dictionary<string, object> Parameters { get; set; }

@objc(Zapic)
public class Zapic: NSObject {

  private static let core = ZapicCore()

  @objc public static var playerId: UUID? {
    return core.playerId
  }

  @objc public static func start(_ version: String) {
    core.start(version: version)
  }

  @objc public static func submitEvent(json: Data) {
    guard let params = ZapicUtils.deserialize(bodyData: json) else {
      ZLog.error("Unable to deserialize event from json data")
      return
    }

    core.submitEvent(eventType: .gameplay, params: params)
  }

  @objc public static func submitEvent(_ params: [String:Any]) {
    core.submitEvent(eventType: .gameplay, params: params)
  }

  @objc public static func show(viewName: String) {
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
