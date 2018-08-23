#import <Foundation/Foundation.h>
#import "ZPlayer.h"
#import "ZScriptMessageHandler.h"

@interface ZPlayerManager : NSObject
@property ZPlayer *player;
- (instancetype)initWithHandler:(ZScriptMessageHandler *)handler;
- (void)addLoginHandler:(void (^)(ZPlayer *))handler;
- (void)addLogoutHandler:(void (^)(ZPlayer *))handler;
@end
