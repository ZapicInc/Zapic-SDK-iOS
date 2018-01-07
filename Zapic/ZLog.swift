//
//  ZLog.swift
//  Zapic
//
//  Created by Daniel Sarfati on 8/2/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

public enum ZLogLevel: String {
  case error = "💩"
  case warn = "❗️"
  case info = "📣"
}

public enum ZLogSource: String {
  case sdk = "SDK"
  case web = "Web"
}

@objc(ZLog)
public class ZLog: NSObject {

  @objc public static var isEnabled = true

  private static var dateFormatter: DateFormatter {
    let dateFormatter: DateFormatter = DateFormatter()
    dateFormatter.dateFormat = "H:mm:ss.SSSS"
    return dateFormatter
  }

  static func error(_ message: String, source: ZLogSource = .sdk ) {
    writeLog(message: message, level: .error, source: source)
  }

  static func warn(_ message: String, source: ZLogSource = .sdk) {
    writeLog(message: message, level: .warn, source: source)
  }

  static func info(_ message: String, source: ZLogSource = .sdk) {
    writeLog(message: message, level: .info, source: source)
  }

  static func log(_ message: String, level: ZLogLevel, source: ZLogSource = .sdk) {
    writeLog(message: message, level: level, source: source)
  }

  private static func writeLog(message: String, level: ZLogLevel, source: ZLogSource) {
    #if DEBUG
      if isEnabled {
        print("\(level.rawValue) [Zapic][\(source.rawValue)][\(dateFormatter.string(from: Date()))] : \(message)")
      }
    #endif
  }
}
