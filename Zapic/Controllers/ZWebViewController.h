#import "ZBackgroundView.h"
#import "ZPlayerManager.h"
#import "ZWebApp.h"

@import UIKit;

typedef NS_ENUM(NSUInteger, ZWebViewStatus) {
    ZWebViewStatusNone,
    ZWebViewStatusLoading,
    ZWebViewStatusAppReady,
    ZWebViewStatusPageReady,
    ZWebViewStatusError,
};

typedef NS_ENUM(NSUInteger, ZEventType) {
    ZEventTypeGameplay,
    ZEventTypeInteraction,
};

@interface ZWebViewController : UIViewController
@property ZPlayerManager *playerManager;

- (void)showPage:(NSString *)pageName;
- (void)submitEvent:(ZEventType)eventType withPayload:(NSObject *)payload;
- (void)closePage;
@end
