//
//  BannerController.swift
//  Zapic
//
//  Created by Daniel Sarfati on 1/31/18.
//  Copyright © 2018 zapic. All rights reserved.
//

import Foundation

extension ZapicViewController: BannerController {

  func receiveBanner(_ json: [String: Any]) {
    guard let msg = json["payload"] as? [String: Any] else {
      ZLog.warn("Received invalid ShowBanner payload")
      return
    }

    guard let title = msg["title"] as? String else {
      ZLog.warn("ShowBanner title is required")
      return
    }

    let icon: UIImage? = decode(base64: msg["icon"] as? String)

    let subTitle = msg["subtitle"] as? String

    let data = msg["data"] as? String

    showBanner(title: title, subTitle: subTitle, icon: icon, data: data)
  }

  /// Trigger when a banner should be shown
  func showBanner(title: String, subTitle: String?, icon: UIImage?, data: String?) {

    var tapCallback:(() -> Void)? = nil

    //If there is data attached to the banner, call the callback
    if data != nil {
      tapCallback = {
        self.handleInteraction(data)
      }
    }

    let banner = Banner(title: title, subtitle: subTitle, icon: icon, didTapBlock: tapCallback)

    banner.dismissesOnTap = true
    banner.show(duration: 300.0)
  }
}
