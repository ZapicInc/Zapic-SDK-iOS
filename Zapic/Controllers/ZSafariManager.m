#import "ZSafariManager.h"
#import "ZLog.h"

@interface ZSafariManager ()
@property (readonly) UIViewController *viewController;
@end

@implementation ZSafariManager

- (instancetype)initWithController:(UIViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)openUrl:(NSURL *)url {
    if (![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) {
        [ZLog warn:@"Unable to open scheme %@ in Safari", url.scheme];
        return;
    }

    [ZLog info:@"Opening url %@ in safari", url.absoluteString];

    UIViewController *svc = [ZSafariManager createSafariViewController:url];

    if (!svc) {
        [ZLog error:@"Unable to create SFSafariViewController"];
        return;
    }

    [svc setValue:self forKey:@"delegate"];
    //    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:url entersReaderIfAvailable:YES];
    //    svc.delegate = self;
    [_viewController presentViewController:svc animated:YES completion:nil];
}

+ (UIViewController *)createSafariViewController:(NSURL *)url {
    id viewControllerClass = NSClassFromString(@"SFSafariViewController");
    if (viewControllerClass) {
        id viewControllerAlloc = [viewControllerClass alloc];
        SEL initSelector = NSSelectorFromString(@"initWithURL:entersReaderIfAvailable:");
        if ([viewControllerAlloc respondsToSelector:initSelector]) {
            [ZLog info:@"SFSafariViewController responds to init selector"];
            IMP initImp = [viewControllerAlloc methodForSelector:initSelector];
            if (initImp) {
                [ZLog info:@"Got init implementation"];
                id (*initFunc)(id, SEL, NSURL *, BOOL) = (void *)initImp;
                return initFunc(viewControllerAlloc, initSelector, url, YES);
            }
        }
    }
    return nil;
}

/**
 Callback with the embedded safari view is "Done"
 
 @param controller The controller that is done
 */
- (void)safariViewControllerDidFinish:(id)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
