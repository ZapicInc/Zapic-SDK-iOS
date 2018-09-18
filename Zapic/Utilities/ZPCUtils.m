#import "ZPCUtils.h"
#import "ZPCLog.h"

@implementation ZPCUtils

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

+ (NSDateFormatter *)getIsoFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    return dateFormatter;
}

+ (NSString *)getIsoNow {
    NSDateFormatter *dateFormatter = [ZPCUtils getIsoFormatter];
    NSDate *now = [NSDate date];
    return [dateFormatter stringFromDate:now];
}

+ (NSDate *)parseDateIso:(NSString *)dateString {
    NSDateFormatter *dateFormatter = [ZPCUtils getIsoFormatter];
    return [dateFormatter dateFromString:dateString];
}

+ (BOOL)isClassPresent:(NSString *)className {
    id nsClass = NSClassFromString(className);

    if (nsClass) {
        return true;
    }

    return false;
}

@end
