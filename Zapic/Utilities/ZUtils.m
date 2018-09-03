#import "ZUtils.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import "ZLog.h"

@implementation ZUtils

+ (UIViewController *)getTopViewController {
    return UIApplication.sharedApplication.delegate.window.rootViewController;
}

+ (UIView *)getTopView {
    UIViewController *root = [self getTopViewController];

    if (root.presentedViewController) {
        return root.presentedViewController.view;
    }

    return root.view;
}

+ (NSDateFormatter *)getIsoFormatter{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
  [dateFormatter setLocale:enUSPOSIXLocale];
  [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
  return dateFormatter;
}

+ (NSString *)getIsoNow {

  NSDateFormatter *dateFormatter = [ZUtils getIsoFormatter];
    NSDate *now = [NSDate date];
    return [dateFormatter stringFromDate:now];
}

+ (NSDate *)parseDateIso:(NSString *)dateString{
  NSDateFormatter *dateFormatter = [ZUtils getIsoFormatter];
  return [dateFormatter dateFromString:dateString];
}

+ (BOOL)isClassPresent:(NSString *)className {
    id nsClass = NSClassFromString(className);

    if (nsClass) {
        return true;
    }

    return false;
}

+ (void)loadSafariServices {
    [self loadFramework:@"SafariServices" withClass:@"SFSafariViewController"];
}

+ (void)loadWebKit {
    [self loadFramework:@"WebKit" withClass:@"WKWebView"];
}

+ (void)loadFramework:(NSString *)framework withClass:(NSString *)className {
    NSString *frameworkLocation;
    if ([ZUtils isClassPresent:className]) {
        [ZLog info:@"%@ framework already present", framework];
        return;
    }

    NSString *frameworkName = [NSString stringWithFormat:@"%@.framework", framework];

#if TARGET_IPHONE_SIMULATOR
    NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
    if (frameworkPath) {
        frameworkLocation = [NSString pathWithComponents:@[frameworkPath, frameworkName, framework]];
    }
#else
    frameworkLocation = [NSString stringWithFormat:@"/System/Library/Frameworks/%@/%@", frameworkName, framework];
#endif

    dlopen([frameworkLocation cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);

    if (![ZUtils isClassPresent:className]) {
        [ZLog error:@"%@ still not present!", framework];
        return;
    } else {
        [ZLog info:@"Succesfully loaded %@ framework", framework];
    }
}

@end
