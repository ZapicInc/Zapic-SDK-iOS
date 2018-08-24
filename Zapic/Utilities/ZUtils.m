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

+ (NSString *)getIsoNow {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];

    NSDate *now = [NSDate date];
    return [dateFormatter stringFromDate:now];
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

+ (id)getObjectFromClass:(NSString *)className {
    id class = NSClassFromString(className);

    if (class) {
        id object = [[class alloc] init];

        if (object) {
            [ZLog info:@"Succesfully created object for %@", className];
            return object;
        }
    }

    [ZLog error:@"Couldn't create object for %@", className];

    return NULL;
}

+ (id)addWKUserScript:(id)wkConfiguration script:(id)script {
    id userContentController = [wkConfiguration valueForKey:@"userContentController"];
    if (userContentController) {
        [ZLog info:@"Got userContentController"];

        SEL addScriptMessageHandlerSelector = NSSelectorFromString(@"addUserScript:");
        if ([userContentController respondsToSelector:addScriptMessageHandlerSelector]) {
            [ZLog info:@"Responds to selector"];
            IMP addScriptMessageHandlerImp = [userContentController methodForSelector:addScriptMessageHandlerSelector];
            if (addScriptMessageHandlerImp) {
                [ZLog info:@"Got addScriptHandler implementation"];
                void (*addScriptMessageHandlerFunc)(id, SEL, id) = (void *)addScriptMessageHandlerImp;

                addScriptMessageHandlerFunc(userContentController, addScriptMessageHandlerSelector, script);

                return wkConfiguration;
            }
        }
    }

    return wkConfiguration;
}

+ (id)addUserContentControllerMessageHandlers:(id)wkConfiguration delegate:(id)delegate handledMessages:(NSArray *)handledMessages {
    id userContentController = [wkConfiguration valueForKey:@"userContentController"];
    if (userContentController) {
        [ZLog info:@"Got userContentController"];

        SEL addScriptMessageHandlerSelector = NSSelectorFromString(@"addScriptMessageHandler:name:");
        if ([userContentController respondsToSelector:addScriptMessageHandlerSelector]) {
            [ZLog info:@"Responds to selector"];
            IMP addScriptMessageHandlerImp = [userContentController methodForSelector:addScriptMessageHandlerSelector];
            if (addScriptMessageHandlerImp) {
                [ZLog info:@"Got addScriptHandler implementation"];
                void (*addScriptMessageHandlerFunc)(id, SEL, id, NSString *) = (void *)addScriptMessageHandlerImp;

                for (NSString *message in handledMessages) {
                    [ZLog info:@"Setting handler for: %@", message];
                    addScriptMessageHandlerFunc(userContentController, addScriptMessageHandlerSelector, delegate, message);
                }

                [wkConfiguration setValue:userContentController forKey:@"userContentController"];

                return wkConfiguration;
            }
        }
    }

    return NULL;
}

+ (id)initWebView:(NSString *)className frame:(CGRect)frame configuration:(id)configuration {
    id webViewClass = NSClassFromString(className);
    if (webViewClass) {
        id webViewAlloc = [webViewClass alloc];
        SEL initSelector = NSSelectorFromString(@"initWithFrame:configuration:");
        if ([webViewAlloc respondsToSelector:initSelector]) {
            [ZLog info:@"WebView responds to init selector"];
            IMP initImp = [webViewAlloc methodForSelector:initSelector];
            if (initImp) {
                [ZLog info:@"Got init implementation"];
                id (*initFunc)(id, SEL, CGRect, id) = (void *)initImp;
                return initFunc(webViewAlloc, initSelector, frame, configuration);
            }
        }
    }

    return NULL;
}

@end
