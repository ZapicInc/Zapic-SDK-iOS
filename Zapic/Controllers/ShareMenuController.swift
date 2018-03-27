//
//  ShareMenuController.swift
//  Zapic
//
//  Created by Daniel Sarfati on 3/26/18.
//  Copyright © 2018 zapic. All rights reserved.
//

import Foundation

internal protocol ShareMenuController {
  func showShareMenu(_ json: [String: Any])
}

extension ZapicViewController: ShareMenuController {

  func showShareMenu(_ json: [String: Any]) {

    guard let msg = json["payload"] as? [String: Any] else {
      ZLog.warn("Received invalid showShareMenu payload")
      return
    }

    var items = [Any]()

    if let shareText = msg["text"] as? String {
      items.append(shareText)
    }
    if let image = decode(base64: msg["image"] as? String) {
      items.append(image)
    }

    if let urlStr =  msg["url"] as? String {
      if let url = URL(string: urlStr) {
        items.append(url)
      }
    }
    let root = UIApplication.shared.delegate?.window??.rootViewController
    let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
       root?.present(vc, animated: true)
  }
}
