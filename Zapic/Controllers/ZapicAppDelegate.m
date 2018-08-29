#import "ZapicAppDelegate.h"
#import "ZLog.h"
#import "ZSelectorHelpers.h"
#import "Zapic.h"

@interface ZapicAppDelegate ()

@end

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

    //Swizzle for deep links
    injectToProperClass(@selector(zapicApplication:openURL:options:), @selector(application:openURL:options:), delegateSubclasses, newClass, delegateClass);

    //Swizzle for universal links
    injectToProperClass(@selector(zapicApplication:continueUserActivity:restorationHandler:), @selector(application:continueUserActivity:restorationHandler:), delegateSubclasses, newClass, delegateClass);

    [self setZapicDelegate:delegate];
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

    [self handleInteraction:url.absoluteString interactionType:@"deepLink" sourceApp:[options objectForKey:UIApplicationOpenURLOptionsSourceApplicationKey]];

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
        [self handleInteraction:userActivity.webpageURL.absoluteString interactionType:@"universalLink" sourceApp:nil];
        handled = YES;
    }

    if ([self respondsToSelector:@selector(zapicApplication:continueUserActivity:restorationHandler:)]) {
        return [self zapicApplication:application continueUserActivity:userActivity restorationHandler:restorationHandler];
    }

    return handled;
}

/**
 Triggers 'handleInteraction' in Zapic

 @param urlString The URL for the interaction.
 @param interactionType The type of interaction.
 @param sourceApp (Optional) The app that triggered the interaction.
 */
- (void)handleInteraction:(nonnull NSString *)urlString interactionType:(nonnull NSString *)interactionType sourceApp:(nullable NSString *)sourceApp {
    NSDictionary *data = @{
        @"url": urlString,
        @"sourceApp": sourceApp,
        @"interactionType": interactionType,
    };

    [Zapic handleInteraction:data];
}

@end
