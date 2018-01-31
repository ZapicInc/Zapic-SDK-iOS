//
//  InjectedJS.swift
//  Zapic
//
//  Created by Daniel Sarfati on 10/18/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

internal let injectedScript = """
window.zapic = {
  environment: 'webview',
  version: 1,
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
