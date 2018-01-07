//
//  ZapicWebClient.swift
//  Zapic
//
//  Created by Daniel Sarfati on 10/17/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

protocol ZapicWebClient {
  var zapicDelegate: ZapicDelegate? { get set }
  func submitEvent(eventType: EventType, params: [String: Any])
  func dispatchToJS(type: WebFunction, payload: Any)
  func dispatchToJS(type: WebFunction, payload: Any, isError: Bool)

  /// Load the web client
  func load()

  /// Attempt to resend all events that we unable to send
  func resendFailedEvents()
}
