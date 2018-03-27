//
//  InjectedJS.swift
//  Zapic
//
//  Created by Daniel Sarfati on 10/18/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

internal func injectedScript(ios: String) -> String {
  return """
window.zapic = {
  environment: 'webview',
  version: 2,
  iosVersion: '\(ios)',
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
