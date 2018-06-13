//
//  InjectedJS.swift
//  Zapic
//
//  Created by Daniel Sarfati on 10/18/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

internal func injectedScript(iosVersion: String, bundleId: String, sdkVersion: String) -> String {
  return """
window.zapic = {
  environment: 'webview',
  version: 3,
  iosVersion: '\(iosVersion)',
  bundleId: '\(bundleId)',
  sdkVersion: '\(sdkVersion)',
  onLoaded: function(action$, publishAction) {
    window.zapic.dispatch = function(action) {
      publishAction(action)
    }

    action$.subscribe(function(action) {
        window.webkit.messageHandlers.dispatch.postMessage(action)
    })
  }
}
"""
}
