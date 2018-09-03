#import <Foundation/Foundation.h>
#import "ZMessageQueue.h"
#import "ZPCCompetition.h"
#import "ZScriptMessageHandler.h"

@interface ZPCQueryManager : NSObject
- (instancetype)initWithMessageHandler:(ZScriptMessageHandler *)messageHandler messageQueue:(ZMessageQueue *)messageQueue;

- (void)getCompetitions:(void (^)(NSArray<ZPCCompetition *> *competitions, NSError *error))completionHandler;
@end
