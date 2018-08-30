#import "ZapicAppDelegate.h"
#import "ZLog.h"
#import "ZNotificationManager.h"
#import "ZSelectorHelpers.h"
#import "Zapic.h"

@implementation ZapicAppDelegate

//Holds the UIApplicationDelegate
static Class delegateClass = nil;

// Store an array of all UIAppDelegate subclasses to iterate over in cases where UIAppDelegate swizzled methods are not overriden in main AppDelegate
// But rather in one of the subclasses
static NSArray *delegateSubclasses = nil;

- (void)setZapicDelegate:(id<UIApplicationDelegate>)delegate {
    [ZLog info:@"Setting Zapic delegate"];

    if (delegateClass) {
        [self setZapicDelegate:delegate];
        return;
    }

    Class newClass = [ZapicAppDelegate class];

    delegateClass = getClassWithProtocolInHierarchy([delegate class], @protocol(UIApplicationDelegate));

    delegateSubclasses = ClassGetSubclasses(delegateClass);

    //Swizzle for didFinishLaunching
    injectToProperClass(@selector(zapicApplication:didFinishLaunchingWithOptions:), @selector(application:didFinishLaunchingWithOptions:), delegateSubclasses, newClass, delegateClass);

    //Swizzle for Push notification
    injectToProperClass(@selector(zapicApplication:didReceiveRemoteNotification:), @selector(application:didReceiveRemoteNotification:), delegateSubclasses, newClass, delegateClass);

    //Swizzle for Push notification
    injectToProperClass(@selector(zapicApplication:didReceiveRemoteNotification:fetchCompletionHandler:), @selector(application:didReceiveRemoteNotification:fetchCompletionHandler:), delegateSubclasses, newClass, delegateClass);

    //Swizzle for deep links
    injectToProperClass(@selector(zapicApplication:openURL:options:), @selector(application:openURL:options:), delegateSubclasses, newClass, delegateClass);

    //Swizzle for universal links
    injectToProperClass(@selector(zapicApplication:continueUserActivity:restorationHandler:), @selector(application:continueUserActivity:restorationHandler:), delegateSubclasses, newClass, delegateClass);

    //Swizzle for push notification registration - success
    injectToProperClass(@selector(zapicApplication:didRegisterForRemoteNotificationsWithDeviceToken:), @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), delegateSubclasses, newClass, delegateClass);

    //Swizzle for push notification registration - failed
    injectToProperClass(@selector(zapicApplication:didFailToRegisterForRemoteNotificationsWithError:), @selector(application:didFailToRegisterForRemoteNotificationsWithError:), delegateSubclasses, newClass, delegateClass);

    [self setZapicDelegate:delegate];
}

/**
 Called when the app opens

 @param application The main application.
 @param launchOptions Launch options
 @return True if this was processed
 */
- (BOOL)zapicApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Zapic registerForPushNotification];

    if ([self respondsToSelector:@selector(zapicApplication:didFinishLaunchingWithOptions:)]) {
        return [self zapicApplication:application didFinishLaunchingWithOptions:launchOptions];
    }
    return YES;
}

/**
 Receives a push notification in background mode.
 
 @param application The main application.
 @param userInfo Push notification info.
 */
- (void)zapicApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [ZNotificationManager receivedNotification:application notificationInfo:userInfo];

    if ([self respondsToSelector:@selector(zapicApplication:didReceiveRemoteNotification:)]) {
        return [self zapicApplication:application didReceiveRemoteNotification:userInfo];
    }
}

/**
 Receives a push notification in background mode.

 @param application The main application.
 @param userInfo Push notification info.
 */
- (void)zapicApplication:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    [ZNotificationManager receivedNotification:application notificationInfo:userInfo];

    if ([self respondsToSelector:@selector(zapicApplication:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
        return [self zapicApplication:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
}

/**
 Receives deep links and sends them to Zapic

 @param app The main application.
 @param url The URL that was opened.
 @param options Extra info about the link.
 @return True if the link was processed.
 */
- (BOOL)zapicApplication:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    [ZLog info:@"Application openedUrl: %@", url.absoluteString];

    [ZapicAppDelegate handleInteraction:url.absoluteString interactionType:@"deepLink" sourceApp:[options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey]];

    if ([self respondsToSelector:@selector(zapicApplication:openURL:options:)]) {
        return [self zapicApplication:app openURL:url options:options];
    }
    return YES;
}

/**
 Receives Universal Links and sends them to Zapic

 @param application The main application.
 @param userActivity The user activity that opened the app.
 @param restorationHandler (Optional) Handler to restore the user activity.
 @return True if the activity was processed.
 */
- (BOOL)zapicApplication:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *_Nullable))restorationHandler {
    [ZLog info:@"Application continueUserActivity: %@", userActivity.activityType];

    BOOL handled = NO;

    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        [ZapicAppDelegate handleInteraction:userActivity.webpageURL.absoluteString interactionType:@"universalLink" sourceApp:nil];
        handled = YES;
    }

    if ([self respondsToSelector:@selector(zapicApplication:continueUserActivity:restorationHandler:)]) {
        return [self zapicApplication:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }

    return handled;
}

- (void)zapicApplication:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [ZNotificationManager setDeviceToken:deviceToken];

    if ([self respondsToSelector:@selector(zapicApplication:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
        [self zapicApplication:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
    }
}

- (void)zapicApplication:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [ZNotificationManager setDeviceTokenError:error.localizedDescription];

    if ([self respondsToSelector:@selector(zapicApplication:didFailToRegisterForRemoteNotificationsWithError:)]) {
        [self zapicApplication:application didFailToRegisterForRemoteNotificationsWithError:error];
    }
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

@end
