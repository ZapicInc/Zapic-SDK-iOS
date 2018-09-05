@import Foundation;
#import "Zapic.h"
#import "ZPCAppDelegate.h"
#import "ZPCLog.h"
#import "ZPCSelectorHelpers.h"
#import "ZPCWebViewController.h"

static BOOL started = NO;
static ZPCWebViewController *_viewController;
static void (^_loginHandler)(ZPCPlayer *);
static void (^_logoutHandler)(ZPCPlayer *);
static void (^_playEventHandler)(ZPCPlayEvent *);

@implementation Zapic : NSObject

#pragma mark - Page names

NSString *const ZPCPageChallenges = @"challenges";
NSString *const ZPCPageCompetition = @"competition";
NSString *const ZPCPageCreateChallenge = @"createChallenge";
NSString *const ZPCPageLogin = @"login";
NSString *const ZPCPageProfile = @"profile";
NSString *const ZPCPageStats = @"stats";

#pragma mark - API Methods

+ (ZPCPlayer *)player {
    return _viewController.playerManager.player;
}

+ (void (^)(ZPCPlayer *))loginHandler {
    return _loginHandler;
}

+ (void (^)(ZPCPlayer *))logoutHandler {
    return _logoutHandler;
}

+ (void (^)(ZPCPlayEvent *))playEventHandler {
    return _playEventHandler;
}

+ (void)setLoginHandler:(void (^)(ZPCPlayer *))loginHandler {
    _loginHandler = loginHandler;
}

+ (void)setLogoutHandler:(void (^)(ZPCPlayer *))logoutHandler {
    _logoutHandler = logoutHandler;
}

+ (void)setPlayEventHandler:(void (^)(ZPCPlayEvent *))playEventHandler {
    _playEventHandler = playEventHandler;
}

+ (void)initialize {
    if (self == [Zapic self]) {
        _viewController = [[ZPCWebViewController alloc] init];

        [_viewController.playerManager addLoginHandler:^(ZPCPlayer *player) {
            if (_loginHandler) {
                _loginHandler(player);
            }
        }];

        [_viewController.playerManager addLogoutHandler:^(ZPCPlayer *player) {
            if (_logoutHandler) {
                _logoutHandler(player);
            }
        }];

        [_viewController.messageHandler addPlayEventHandler:^(ZPCPlayEvent *playEvent) {
            if (_playEventHandler) {
                _playEventHandler(playEvent);
            }
        }];
    }
}

+ (void)start {
    if (started) {
        [ZPCLog info:@"Zapic is already started. Start should only be called once"];
        return;
    }
    started = true;

    [ZPCLog info:@"Starting Zapic"];
}

+ (void)showPage:(NSString *)pageName {
    [_viewController showPage:pageName];
}

+ (void)showDefaultPage {
    [self showPage:@"default"];
}

+ (void)handleInteraction:(NSDictionary *)data {
    if (!data) {
        [ZPCLog warn:@"Missing data, unable to handleInteraction"];
        return;
    }

    [_viewController submitEvent:ZPCEventTypeInteraction withPayload:data];
}

+ (void)handleInteractionString:(NSString *)json {
    if (!json) {
        [ZPCLog warn:@"Missing handleInteraction string"];
        return;
    }

    NSError *error;
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:kNilOptions
                                                                   error:&error];
    if (!jsonResponse) {
        [ZPCLog warn:@"Interaction string must be valid json"];
        return;
    }

    [self handleInteraction:jsonResponse];
}

+ (void)submitEvent:(NSDictionary *)parameters {
    [_viewController submitEvent:ZPCEventTypeGameplay withPayload:parameters];
}

+ (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [_viewController.notificationManager registerForPushNotifications];
}

+ (void)continueUserActivity:(NSUserActivity *)userActivity {
    [ZPCLog info:@"Application continueUserActivity: %@", userActivity.activityType];

    BOOL handled = NO;

    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [Zapic handleInteraction:userActivity.webpageURL.absoluteString interactionType:@"universalLink" sourceApp:nil];
        handled = YES;
    }
}

+ (void)openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [ZPCLog info:@"Application openedUrl: %@", url.absoluteString];

    [Zapic handleInteraction:url.absoluteString interactionType:@"deepLink" sourceApp:[options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey]];
}

+ (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [_viewController.notificationManager setDeviceToken:deviceToken];
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [_viewController.notificationManager receivedNotification:userInfo];
}

/**
 Triggers 'handleInteraction' in Zapic
 
 @param urlString The URL for the interaction.
 @param interactionType The type of interaction.
 @param sourceApp (Optional) The app that triggered the interaction.
 */
+ (void)handleInteraction:(nonnull NSString *)urlString interactionType:(nonnull NSString *)interactionType sourceApp:(nullable NSString *)sourceApp {
    NSDictionary *data = @{
        @"url": urlString,
        @"sourceApp": sourceApp,
        @"interactionType": interactionType,
    };

    [Zapic handleInteraction:data];
}

+ (void)getCompetitions:(void (^)(NSArray<ZPCCompetition *> *competitions, NSError *error))completionHandler {
    [_viewController.queryManager getCompetitions:completionHandler];
}

@end

// Swizzles UIApplication class to swizzling the following:
//   - UIApplication
//      - setDelegate:
//        - Used to swizzle all UIApplicationDelegate selectors on the passed in class.
//        - Almost always this is the AppDelegate class but since UIApplicationDelegate is an "interface" this could be any class.
//
//  Note1: Do NOT move this category to it's own file. This is required so when the app developer calls Zapic.start() this +load
//            will fire along with it. This is due to how iOS loads .m files into memory instead of classes.
//  Note2: Do NOT directly add swizzled selectors to this category as if this class is loaded into the runtime twice unexpected results will occur.
//            The zapicLoadedTagSelector: selector is used a flag to prevent double swizzling if this library is loaded twice.
@implementation UIApplication (Zapic)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
+ (void)load {
    [ZPCLog info:@"UIApplication(Zapic) load"];

    // Prevent Xcode storyboard rendering process from crashing with custom IBDesignable Views
    // https://github.com/OneSignal/OneSignal-iOS-SDK/issues/160
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    if ([[processInfo processName] isEqualToString:@"IBDesignablesAgentCocoaTouch"])
        return;

    // Double loading of class detection.
    BOOL existing = injectSelector([ZPCAppDelegate class], @selector(zapicLoadedTagSelector), self, @selector(zapicLoadedTagSelector));

    if (existing) {
        [ZPCLog warn:@"Already swizzled UIApplication.setDelegate. Make sure the Zapic library wasn't loaded into the runtime twice!"];
        return;
    }

    // Swizzle - UIApplication delegate
    injectToProperClass(@selector(setZapicDelegate:), @selector(setDelegate:), @[], [ZPCAppDelegate class], [UIApplication class]);
}

+ (void)zapicLoadedTagSelector {
}

@end
