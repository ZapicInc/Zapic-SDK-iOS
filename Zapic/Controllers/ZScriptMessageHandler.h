#import <Foundation/Foundation.h>
#import "ZAppStatusMessage.h"
#import "ZBannerMessage.h"
#import "ZPlayer.h"
#import "ZShareMessage.h"

static NSString *const ScriptMethodName = @"dispatch";

@interface ZScriptMessageHandler : NSObject
- (void)userContentController:(id)userContentController didReceiveScriptMessage:(id)message;
- (void)addAppStatusHandler:(void (^)(ZAppStatusMessage *))handler;
- (void)addBannerHandler:(void (^)(ZBannerMessage *))handler;
- (void)addLoginHandler:(void (^)(ZPlayer *))handler;
- (void)addLogoutHandler:(void (^)(void))handler;
- (void)addClosePageHandler:(void (^)(void))handler;
- (void)addPageReadyHandler:(void (^)(void))handler;
- (void)addShowPageHandler:(void (^)(void))handler;
- (void)addShowShareHandler:(void (^)(ZShareMessage *))handler;
@end
