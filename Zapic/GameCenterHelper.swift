//
//  GameCenterHelper.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import GameKit

class GameCenterHelper {
    static func generateSignature(completion: @escaping (String) -> Void) {

        let localPlayer = GKLocalPlayer.localPlayer()

        localPlayer.authenticateHandler = {(gameCenterVC: UIViewController!, gameCenterError: Error!) -> Void in

            if gameCenterVC != nil {
                print("Zapic - show VC")

                UIApplication.shared.keyWindow?.rootViewController?.present(gameCenterVC, animated: true, completion: nil)
            } else if localPlayer.isAuthenticated {
                print("Authentication with Game Center success")
                self.generateIdentityInfo(completion:completion)

            } else {
                print(gameCenterError.localizedDescription)
            }
        }
    }

    static func generateIdentityInfo(completion: @escaping (String) -> Void) {
        let player = GKLocalPlayer.localPlayer()

        player.generateIdentityVerificationSignature { (publicKeyUrl: URL!, signature: Data!, salt: Data!, timestamp: UInt64, error: Error!) -> Void in

            if let err = error {
                print(err.localizedDescription)
                print("Error generating verification signature")
                return; //some sort of error, can't authenticate right now
            }

            let signatureStr = signature.base64EncodedString()

            let saltStr = salt.base64EncodedString()

            let timestampStr = String(timestamp)

            let dict = ["playerId": player.playerID,
                        "bundleId": Bundle.main.bundleIdentifier,
                        "publicKeyUrl": publicKeyUrl.absoluteString,
                        "signature": signatureStr,
                        "timestamp": timestampStr,
                        "salt": saltStr
            ]

            if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options:.prettyPrinted) {

                let jsonStr = String(data: jsonData, encoding: .utf8)

                completion(jsonStr!)
            }
        }
    }
}
