#import "ZNotificationManager.h"
#import "ZLog.h"
#import "Zapic.h"

@import UserNotifications;

static BOOL registered = NO;
static ZMessageQueue *_messageQueue;

@implementation ZNotificationManager

+ (ZMessageQueue *)messageQueue {
    return _messageQueue;
}

+ (void)setMessageQueue:(ZMessageQueue *)messageQueue {
    _messageQueue = messageQueue;
}

+ (void)registerForPushNotifications {
    if (registered) {
        [ZLog warn:@"Already registered for push notifications, ignoring"];
        return;
    }

    registered = YES;

    [ZLog info:@"Registering for push notifications"];

    //iOS 10 and above
    if (@available(iOS 10.0, *)) {
        id callback = ^(BOOL granted, NSError *_Nullable error) {
            //If the user accepts the push notifications
            if (granted) {
                [ZLog info:@"Notifications permission are granted"];

                [UNUserNotificationCenter.currentNotificationCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *_Nonnull settings) {
                    [ZLog info:@"Notification authorization status %ld", (long)settings.authorizationStatus];

                    if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                        dispatch_async(dispatch_get_main_queue(), ^(void) {
                            [UIApplication.sharedApplication registerForRemoteNotifications];
                        });
                    }
                }];
            } else {
                [ZLog info:@"Notifications permission are not granted"];
            }
        };

        //Request permission to send push notifications, aka the popup
        [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge) completionHandler:callback];
    } else {
        //iOS 9
        //      let settings = UIUserNotificationSettings(forTypes: [.Sound, .Alert, .Badge], categories: nil)
        //      UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
        [UIApplication.sharedApplication registerUserNotificationSettings:settings];

        // This is an asynchronous method to retrieve a Device Token
        // Callbacks are in AppDelegate.swift
        // Success = didRegisterForRemoteNotificationsWithDeviceToken
        // Fail = didFailToRegisterForRemoteNotificationsWithError
        //      UIApplication.sharedApplication().registerForRemoteNotifications()
        [UIApplication.sharedApplication registerForRemoteNotifications];
    }
}

+ (void)setDeviceTokenError:(NSString *)error {
    [_messageQueue sendMessage:ZWebFunctionSetDeviceToken withPayload:error isError:YES];
}

+ (void)setDeviceToken:(NSData *)deviceToken {
    if (!_messageQueue) {
        [ZLog error:@"No message queue, unable to update the device token"];
        return;
    }

    const unsigned *tokenBytes = [deviceToken bytes];

    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                                                    ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                                                    ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                                                    ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];

    NSDictionary *msg = @{
        @"deviceToken": hexToken,
    };

    [_messageQueue sendMessage:ZWebFunctionSetDeviceToken withPayload:msg];
}

+ (void)receivedNotification:(UIApplication *)application notificationInfo:(NSDictionary *)userInfo {
    UIApplicationState state = [application applicationState];
    NSDictionary *aps = [userInfo objectForKey:@"aps"];

    // user tapped notification while app was in background or closed
    if (state == UIApplicationStateInactive || state == UIApplicationStateBackground) {
        [_messageQueue sendMessage:ZWebFunctionNotificationOpened withPayload:aps];
    } else {
        // App is in UIApplicationStateActive (running in foreground)
        [_messageQueue sendMessage:ZWebFunctionNotificationReceived withPayload:aps];
    }
}

@end
