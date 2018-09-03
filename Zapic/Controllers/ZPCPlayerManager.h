@import Foundation;
#import "ZPCPlayer.h"
#import "ZPCScriptMessageHandler.h"

@interface ZPCPlayerManager : NSObject
@property ZPCPlayer *player;
- (instancetype)initWithHandler:(ZPCScriptMessageHandler *)handler;
- (void)addLoginHandler:(void (^)(ZPCPlayer *))handler;
- (void)addLogoutHandler:(void (^)(ZPCPlayer *))handler;
@end
