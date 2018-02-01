//
//  ZapicWebClient.swift
//  Zapic
//
//  Created by Daniel Sarfati on 10/17/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

protocol WebApp {
  var zapicDelegate: ZapicDelegate? { get set }
//  /// Attempt to resend all events that we unable to send
//  func resendFailedEvents()
//  func submitEvent(eventType: EventType, params: [String: Any])
//  func dispatchToJS(type: WebFunction, payload: Any)
//  func dispatchToJS(type: WebFunction, payload: Any, isError: Bool)

  /// Load the web client
  func load()

//  /// Attempt to resend all events that we unable to send
//  func resendFailedEvents()
}
