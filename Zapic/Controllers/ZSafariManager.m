#import "ZSafariManager.h"
#import "ZLog.h"

@import SafariServices;

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

    SFSafariViewController *svc = [[SFSafariViewController alloc] initWithURL:url];

    if (!svc) {
        [ZLog error:@"Unable to create SFSafariViewController"];
        return;
    }

    [svc setValue:self forKey:@"delegate"];
    [_viewController presentViewController:svc animated:YES completion:nil];
}

/**
 Callback with the embedded safari view is "Done"
 
 @param controller The controller that is done
 */
- (void)safariViewControllerDidFinish:(id)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
