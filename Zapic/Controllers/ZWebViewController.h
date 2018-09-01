#import "ZBackgroundView.h"
#import "ZNotificationManager.h"
#import "ZPCQueryManager.h"
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
@property (readonly) ZPlayerManager *playerManager;
@property (readonly) ZNotificationManager *notificationManager;
@property (nonnull, readonly) ZPCQueryManager *queryManager;

- (void)showPage:(NSString *)pageName;
- (void)submitEvent:(ZEventType)eventType withPayload:(NSObject *)payload;
- (void)closePage;
@end
