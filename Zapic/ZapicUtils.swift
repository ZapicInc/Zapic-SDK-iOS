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
        case is [String:Any]:
            if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                return String(data: jsonData, encoding: .utf8)
            }
        default:
            return String(describing:data)
        }

        return nil
    }

    static func deserialize(bodyData: Data) -> [String:Any]? {
        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
            let payload = json as? [String: Any] else {
                return nil
        }
        return payload
    }
}
