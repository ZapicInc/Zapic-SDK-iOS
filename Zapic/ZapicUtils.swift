//
//  ZapicUtils.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/21/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

class ZapicUtils {

    static func serialize(data: Any) -> String? {

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

    static func deserialize(bodyData: Data) -> [String: Any]? {
        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
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
      return "http://localhost:3000"// "https://app.zapic.net"
    }
  }
}
