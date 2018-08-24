#import "ZInjectedJS.h"

@implementation ZInjectedJS

+ (NSString *)getInjectedScript:(NSString *)iosVersion bundleId:(NSString *)bundleId sdkVersion:(NSString *)sdkVersion {
    return [NSString stringWithFormat:
                         @"window.zapic = {"
                          "environment: 'webview',"
                          "version: 3,"
                          "iosVersion: '%@',"
                          "bundleId: '%@',"
                          "sdkVersion: '%@',"
                          "onLoaded: function(action$, publishAction) {"
                          "window.zapic.dispatch = function(action) {"
                          "publishAction(action)"
                          "};"
                          "action$.subscribe(function(action) {"
                          "window.webkit.messageHandlers.dispatch.postMessage(action)"
                          "});"
                          "}"
                          "}",
                         iosVersion, bundleId, sdkVersion];
}

@end
