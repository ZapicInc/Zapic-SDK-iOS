#import <Foundation/Foundation.h>
#import "ZPCCompetition.h"
#import "ZPCMessageQueue.h"
#import "ZPCScriptMessageHandler.h"
#import "ZPCStatistic.h"

@interface ZPCQueryManager : NSObject

- (instancetype)initWithMessageHandler:(ZPCScriptMessageHandler *)messageHandler messageQueue:(ZPCMessageQueue *)messageQueue;

/**
 Gets the list of competitions.

 @param completionHandler Callback handler.
 */
- (void)getCompetitions:(void (^)(NSArray<ZPCCompetition *> *competitions, NSError *error))completionHandler;

/**
 Gets the list of competitions.
 
 @param completionHandler Callback handler.
 */
- (void)getStatistics:(void (^)(NSArray<ZPCStatistic *> *statistics, NSError *error))completionHandler;
@end
