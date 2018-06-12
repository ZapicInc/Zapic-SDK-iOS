//
//  ZapicUtils.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/21/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

@objc(ZapicUtils)
public class ZapicUtils: NSObject {

  @objc
  public static func encodePlayer(object: ZapicPlayer) -> String? {
    do {
      let data = try JSONEncoder().encode(object)
      return String(data: data, encoding: .utf8)
    } catch {
      return nil
    }
  }

  public static func serialize(data: Any) -> String? {

    switch data {
    case is [String: Any]:
      if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
        return String(data: jsonData, encoding: .utf8)
      }
    default:
      return String(describing: data)
    }

    return nil
  }

  @objc
  public static func deserialize(_ bodyData: String) -> [String: Any]? {
    let data = bodyData.data(using: .utf8)!
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
      let payload = json as? [String: Any] else {
        return nil
    }
    return payload
  }

  static func formatString(message: String, args: [String]?) -> String {

    guard let args = args else {
      return message
    }

    if args.count == 0 {
      return message
    }

    return message.replaceSubstrings(string: "%s", args: args)
  }

  static func appUrl() -> String {
    if let clientUrl = UserDefaults.standard.string(forKey: "ZAPIC_URL"), !clientUrl.isEmpty {
      return clientUrl
    } else {
      return "https://app.zapic.netd"
    }
  }
}
