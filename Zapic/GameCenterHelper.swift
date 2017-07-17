//
//  GameCenterHelper.swift
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import GameKit
import RxSwift

class GameCenterHelper {
    static func generateSignature() -> Observable<[String:Any]> {

        return gcAuth().flatMap { player in generateIdentityInfo(player: player) }
    }

    private static func gcAuth() -> Observable<GKLocalPlayer> {

        return Observable.create { observable in

            let localPlayer = GKLocalPlayer.localPlayer()

            localPlayer.authenticateHandler = {(gameCenterVC: UIViewController!, gameCenterError: Error!) -> Void in

                if let gameCenterError = gameCenterError {
                    observable.onError(gameCenterError)
                }

                if gameCenterVC != nil {
                    print("Zapic - showing GameCenter View")

                    UIApplication.shared.keyWindow?.rootViewController?.present(gameCenterVC, animated: true, completion: nil)

                } else if localPlayer.isAuthenticated {

                    print("Authentication with Game Center success")

                    observable.onNext(localPlayer)
                    observable.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    private static func generateIdentityInfo(player: GKLocalPlayer) -> Observable<[String:Any]> {
        return Observable.create { observable in
            
            print("Generating identity signature")

            player.generateIdentityVerificationSignature { (publicKeyUrl: URL!, signature: Data!, salt: Data!, timestamp: UInt64, error: Error!) -> Void in

                if let err = error {
                    observable.onError(err)
                    print(err.localizedDescription)
                    print("Error generating verification signature")
                }
                
                print("Generated identity signature")

                let signatureStr = signature.base64EncodedString()

                let saltStr = salt.base64EncodedString()

                let timestampStr = String(timestamp)

                let dict = ["playerId": player.playerID ?? "",
                            "bundleId": Bundle.main.bundleIdentifier ?? "",
                            "publicKeyUrl": publicKeyUrl.absoluteString,
                            "signature": signatureStr,
                            "timestamp": timestampStr,
                            "salt": saltStr
                ]

                observable.onNext(dict)
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
}
