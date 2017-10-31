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

  ///  Generates the current player's GameCenter signature
  ///
  /// - Parameter completionHandler: Callback when the signature has been generated
  static func generateSignature(completionHandler: @escaping ([String:Any]?, Error?) -> Void) {
    gameCenterAuthenticate { (player, error) in
      guard error == nil else {
        ZLog.error("Error authenticaing player")
        completionHandler(nil, error)
        return
      }

      guard let localPlayer = player else {
        ZLog.error("Error authenticaing player")
        completionHandler(nil, ZapicError.invalidPlayer)
        return
      }

      //Generate the identity info once the player is authenticated with GameCenter
      generateIdentityInfo(player: localPlayer) { (signature, error) in

        guard error == nil else {
          completionHandler(nil, error)
          return
        }

        guard signature != nil else {
          completionHandler(nil, ZapicError.invalidAuthSignature)
          return
        }

        completionHandler(signature, nil)
      }
    }
  }

  private static func gameCenterAuthenticate(completionHandler:@escaping (GKLocalPlayer?, Error?) -> Void) {

    let localPlayer = GKLocalPlayer.localPlayer()

    if localPlayer.isAuthenticated {
      completionHandler(localPlayer, nil)
      return
    }

    localPlayer.authenticateHandler = {(gameCenterVC: UIViewController!, gameCenterError: Error!) -> Void in

      guard gameCenterError == nil else {
        completionHandler(nil, gameCenterError)
        return
      }

      if gameCenterVC != nil {
        ZLog.info("Zapic - showing GameCenter View")

        UIApplication.shared.keyWindow?.rootViewController?.present(gameCenterVC, animated: true, completion: nil)
      }

      if localPlayer.isAuthenticated {
        ZLog.info("Authentication with Game Center success")

        completionHandler(localPlayer, nil)
      }
    }
  }

  private static func generateIdentityInfo(player: GKLocalPlayer, completionHandler: @escaping ([String:Any]?, Error?) -> Void) {
    ZLog.info("Generating identity signature")

    player.generateIdentityVerificationSignature { (publicKeyUrl: URL!, signature: Data!, salt: Data!, timestamp: UInt64, error: Error!) -> Void in

      guard error == nil else {
        ZLog.error("Error generating verification signature")
        completionHandler(nil, error)
        return
      }

      ZLog.info("Generated identity signature")

      let signatureStr = signature.base64EncodedString()

      let saltStr = salt.base64EncodedString()

      let timestampStr = String(timestamp)

      let dict = ["playerId": player.playerID ?? "",
                  "displayName": player.alias ?? "",
                  "bundleId": Bundle.main.bundleIdentifier ?? "",
                  "publicKeyUrl": publicKeyUrl.absoluteString,
                  "signature": signatureStr,
                  "timestamp": timestampStr,
                  "salt": saltStr
      ]

      completionHandler(dict, nil)
    }
  }
}
