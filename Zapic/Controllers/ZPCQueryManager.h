#import <Foundation/Foundation.h>
#import "ZPCCompetition.h"
#import "ZPCMessageQueue.h"
#import "ZPCScriptMessageHandler.h"

@interface ZPCQueryManager : NSObject
- (instancetype)initWithMessageHandler:(ZPCScriptMessageHandler *)messageHandler messageQueue:(ZPCMessageQueue *)messageQueue;

- (void)getCompetitions:(void (^)(NSArray<ZPCCompetition *> *competitions, NSError *error))completionHandler;
@end
