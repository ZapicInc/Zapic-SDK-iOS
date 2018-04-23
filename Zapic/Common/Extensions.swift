//
//  Extensions.swift
//  Zapic
//
//  Created by Daniel Sarfati on 8/3/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

extension Formatter {
  static let iso8601: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
    return formatter
  }()
}
extension Date {
  var iso8601: String {
    return Formatter.iso8601.string(from: self)
  }
}

extension String {
  var dateFromISO8601: Date? {
    return Formatter.iso8601.date(from: self)   // "Mar 22, 2017, 10:22 AM"
  }
}

extension UIDevice {
  var iPhoneX: Bool {
    return UIScreen.main.nativeBounds.height == 2436
  }
}
