//
//  ZLog.swift
//  Zapic
//
//  Created by Daniel Sarfati on 8/2/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

public class ZLog {

  public static var isEnabled = false

  private static var dateFormatter: DateFormatter {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "H:mm:ss.SSSS"
    return dateFormatter
  }

  static func error(_ message: String) {
    log(message: message, icon: "💩")
  }

  static func warn(_ message: String) {
    log(message: message, icon: "❗️")
  }

  static func info(_ message: String) {
    log(message: message, icon: "📣")
  }

  static func debug(_ message: String) {
    log(message: message, icon: "🐞")
  }

  private static func log(message: String, icon: String) {
    #if DEBUG
      if isEnabled {
        print("\(icon) [Zapic][\(dateFormatter.string(from: Date()))] : \(message)")
      }
    #endif
  }
}
