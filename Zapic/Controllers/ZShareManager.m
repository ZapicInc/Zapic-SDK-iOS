#import "ZShareManager.h"

@interface ZShareManager ()
@property (readonly) UIViewController *viewController;
@end

@implementation ZShareManager

- (instancetype)initWithController:(UIViewController *)viewController {
    if (self = [super init]) {
        _viewController = viewController;
    }
    return self;
}

- (void)share:(ZShareMessage *)message {
    //This assumes that the ZapicViewController is being displayed when the share message is sent.
    //Otherwise this will fail

    NSMutableArray *objectsToShare = [NSMutableArray array];

    if (message.text) {
        [objectsToShare addObject:message.text];
    }

    if (message.image) {
        [objectsToShare addObject:message.image];
    }

    if (message.url) {
        [objectsToShare addObject:message.url];
    }

    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];

    [_viewController presentViewController:shareController animated:YES completion:nil];
}

@end
