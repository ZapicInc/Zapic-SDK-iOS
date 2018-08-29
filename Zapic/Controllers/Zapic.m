@import Foundation;
#import "Zapic.h"
#import "ZLog.h"
#import "ZSelectorHelpers.h"
#import "ZWebViewController.h"
#import "ZapicAppDelegate.h"

static bool started = false;
static ZWebViewController *_viewController;
static void (^_loginHandler)(ZPlayer *);
static void (^_logoutHandler)(ZPlayer *);

@implementation Zapic : NSObject

+ (ZPlayer *)player {
    return _viewController.playerManager.player;
}

+ (void (^)(ZPlayer *))loginHandler {
    return _loginHandler;
}

+ (void (^)(ZPlayer *))logoutHandler {
    return _logoutHandler;
}

+ (void)setLoginHandler:(void (^)(ZPlayer *))loginHandler {
    _loginHandler = loginHandler;
}

+ (void)setLogoutHandler:(void (^)(ZPlayer *))logoutHandler {
    _logoutHandler = logoutHandler;
}

+ (void)initialize {
    if (self == [Zapic self]) {
        _viewController = [[ZWebViewController alloc] init];

        [_viewController.playerManager addLoginHandler:^(ZPlayer *player) {
            if (_loginHandler) {
                _loginHandler(player);
            }
        }];

        [_viewController.playerManager addLogoutHandler:^(ZPlayer *player) {
            if (_logoutHandler) {
                _logoutHandler(player);
            }
        }];
    }
}

+ (void)start {
    if (started) {
        [ZLog info:@"Zapic is already started. Start should only be called once"];
        return;
    }
    started = true;

    [ZLog info:@"Starting Zapic"];
}

+ (void)showPage:(NSString *)pageName {
    [_viewController showPage:pageName];
}

+ (void)showDefaultPage {
    [self showPage:@"default"];
}

+ (void)handleInteraction:(NSDictionary *)data {
    if (!data) {
        [ZLog warn:@"Missing data, unable to handleInteraction"];
        return;
    }

    [_viewController submitEvent:ZEventTypeInteraction withPayload:data];
}

+ (void)handleInteractionString:(NSString *)json {
    if (!json) {
        [ZLog warn:@"Missing handleInteraction string"];
        return;
    }

    NSError *error;
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    if (!jsonResponse) {
        [ZLog warn:@"Interaction string must be valid json"];
        return;
    }

    [self handleInteraction:jsonResponse];
}

+ (void)submitEvent:(NSDictionary *)parameters {
    [_viewController submitEvent:ZEventTypeGameplay withPayload:parameters];
}

@end

// Swizzles UIApplication class to swizzling the following:
//   - UIApplication
//      - setDelegate:
//        - Used to swizzle all UIApplicationDelegate selectors on the passed in class.
//        - Almost always this is the AppDelegate class but since UIApplicationDelegate is an "interface" this could be any class.
//   - UNUserNotificationCenter
//     - setDelegate:
//        - For iOS 10 only, swizzle all UNUserNotificationCenterDelegate selectors on the passed in class.
//         -  This may or may not be set so we set our own now in registerAsUNNotificationCenterDelegate to an empty class.
//
//  Note1: Do NOT move this category to it's own file. This is required so when the app developer calls OneSignal.initWithLaunchOptions this load+
//            will fire along with it. This is due to how iOS loads .m files into memory instead of classes.
//  Note2: Do NOT directly add swizzled selectors to this category as if this class is loaded into the runtime twice unexpected results will occur.
//            The oneSignalLoadedTagSelector: selector is used a flag to prevent double swizzling if this library is loaded twice.
@implementation UIApplication (Zapic)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
+ (void)load {
    [ZLog info:@"UIApplication(Zapic) load"];

    // Prevent Xcode storyboard rendering process from crashing with custom IBDesignable Views
    // https://github.com/OneSignal/OneSignal-iOS-SDK/issues/160
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if ([[processInfo processName] isEqualToString:@"IBDesignablesAgentCocoaTouch"])
        return;

    // Double loading of class detection.
    BOOL existing = injectSelector([ZapicAppDelegate class], @selector(oneSignalLoadedTagSelector), self, @selector(oneSignalLoadedTagSelector));

    if (existing) {
        [ZLog warn:@"Already swizzled UIApplication.setDelegate. Make sure the Zapic library wasn't loaded into the runtime twice!"];
        return;
    }

    // Swizzle - UIApplication delegate
    injectToProperClass(@selector(setZapicDelegate:), @selector(setDelegate:), @[], [ZapicAppDelegate class], [UIApplication class]);

    //TODO
    //  injectToProperClass(@selector(onesignalSetApplicationIconBadgeNumber:), @selector(setApplicationIconBadgeNumber:), @[], [OneSignalAppDelegate class], [UIApplication class]);
    //
    //  [self setupUNUserNotificationCenterDelegate];
}

+ (void)oneSignalLoadedTagSelector {
}

@end
