//
//  TokenManager.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

class ZapicKey {
    static let Token = "ZAPIC_TOKEN"
}

class TokenManager {

    static let Issuer = "https://api.zapic.com"

    private(set) var token = ""

    private var bundleId: String

    init(bundleId: String) {
        self.bundleId = bundleId
        self.loadToken()
    }

    private func loadToken() {
        if let loadedToken = UserDefaults.standard.string(forKey: ZapicKey.Token) {
            token = loadedToken
        }
    }

    func hasValidToken() -> Bool {
        return !token.isEmpty
    }

    func updateToken(newToken: String) {

        if isValidToken(token: newToken) {
            setToken(newToken: newToken)
        } else {
            clearToken()
        }
    }

    private func setToken(newToken: String) {
        UserDefaults.standard.setValue(newToken, forKey: ZapicKey.Token)
        token = newToken

    }

    func clearToken() {
        UserDefaults.standard.setValue("", forKey: ZapicKey.Token)
        token = ""

    }

    private func isValidToken(token: String) -> Bool {

        let parts = token.components(separatedBy: ".")

        guard parts.count == 3 else {

            return false
        }

        guard let pld = TokenManager.decodePart(part: parts[1]) else {
            return false
        }

        guard let iss = pld["iss"] as? String,
            let aud = (pld["aud"] as? String)?.components(separatedBy: ":"),
            UUID(uuidString: (pld["sub"] as? String)!) != nil,
            pld["exp"] as? Int != nil,
            pld["iat"] as? Int != nil
            else {
                return false
        }

        guard aud.count == 2 && aud[0] == "2" && aud[1] == bundleId else {
            print("Invalid token: Audience")
            return false
        }

        if iss != TokenManager.Issuer {
            print("Invalid token: Issuer")
            return false
        }

        return true
    }

    private static func decodePart(part: String) -> [String:Any]? {
        guard let bodyData = part.fromBase64() else {
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
            let payload = json as? [String: Any] else {
                return nil
        }

        return payload
    }
}

extension String {

    func fromBase64() -> Data? {

        var base64Str = self as String
        if base64Str.characters.count % 4 != 0 {
            let padlen = 4 - base64Str.characters.count % 4
            base64Str += String(repeating: "=", count: padlen)
        }

        if let data = Data(base64Encoded: base64Str, options: []) {
            //            let str = String(data: data, encoding: String.Encoding.utf8) {
            return data
        }
        return nil
    }
}
