#import "ZPCInjectedJS.h"
@import UIKit;

@implementation ZPCInjectedJS

+ (NSString *)getInjectedScript {
    //Gets the info to be injected
    NSString *sdkVersion = ([NSBundle bundleForClass:[self class]].infoDictionary)[@"CFBundleShortVersionString"];
    NSDictionary *appInfo = NSBundle.mainBundle.infoDictionary;
    NSString *appVersion = appInfo[@"CFBundleShortVersionString"];
    NSString *appBuild = appInfo[@"CFBundleVersion"];
    NSString *bundleId = NSBundle.mainBundle.bundleIdentifier;
    NSString *deviceId = UIDevice.currentDevice.identifierForVendor.UUIDString;
    NSString *iosVersion = UIDevice.currentDevice.systemVersion;
    NSString *installId = [self installId];
    return [NSString stringWithFormat:
                         @"window.zapic = {"
                          "environment: 'webview',"
                          "version: 3,"
                          "iosVersion: '%@',"
                          "bundleId: '%@',"
                          "sdkVersion: '%@',"
                          "installId: '%@',"
                          "deviceId: '%@',"
                          "appVersion: '%@',"
                          "appBuild: '%@',"
                          "onLoaded: function(action$, publishAction) {"
                          "window.zapic.dispatch = function(action) {"
                          "publishAction(action)"
                          "};"
                          "action$.subscribe(function(action) {"
                          "window.webkit.messageHandlers.dispatch.postMessage(action)"
                          "});"
                          "}"
                          "}",
                         iosVersion, bundleId, sdkVersion, installId, deviceId, appBuild, appVersion];
}

+ (NSString *)installId {
    NSString *const installKey = @"zapic-install-id";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *installId = [userDefaults stringForKey:installKey];

    //If an install id was not found, create one
    if (!installId) {
        installId = [NSUUID UUID].UUIDString;
        [userDefaults setObject:installId forKey:installKey];
    }

    return installId;
}

@end
