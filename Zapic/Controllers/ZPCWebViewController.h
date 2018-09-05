#import "ZPCBackgroundView.h"
#import "ZPCNotificationManager.h"
#import "ZPCPlayerManager.h"
#import "ZPCQueryManager.h"
#import "ZPCWebApp.h"

@import UIKit;

typedef NS_ENUM(NSUInteger, ZPCEventType) {
    ZPCEventTypeGameplay,
    ZPCEventTypeInteraction,
};

@interface ZPCWebViewController : UIViewController
@property (readonly) ZPCPlayerManager *playerManager;
@property (readonly) ZPCNotificationManager *notificationManager;
@property (readonly, strong) ZPCScriptMessageHandler *messageHandler;
@property (nonnull, readonly) ZPCQueryManager *queryManager;

- (void)showPage:(NSString *)pageName;
- (void)submitEvent:(ZPCEventType)eventType withPayload:(NSObject *)payload;
- (void)closePage;
@end
