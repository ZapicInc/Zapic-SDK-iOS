#import "ZPCQueryManager.h"
#import "ZPCLog.h"

typedef void (^ResponseBlock)(id response, NSError *error);

@interface ZPCQueryManager ()
@property (readonly) ZPCScriptMessageHandler *messageHandler;
@property (readonly) ZPCMessageQueue *messageQueue;
@property (nonnull, readonly) NSMutableDictionary<NSString *, ResponseBlock> *requests;
@end
@implementation ZPCQueryManager

static NSString *const ZPCCompetitionList = @"competitionList";
static NSString *const ZPCStatistics = @"statistics";

- (instancetype)initWithMessageHandler:(ZPCScriptMessageHandler *)messageHandler messageQueue:(ZPCMessageQueue *)messageQueue {
    if (self = [super init]) {
        _messageQueue = messageQueue;
        _messageHandler = messageHandler;
        _requests = [[NSMutableDictionary alloc] init];

        __weak typeof(self) weakSelf = self;

        [_messageHandler addQueryResponseHandler:^(NSDictionary *message) {
            [weakSelf handleResponse:message];
        }];
    }
    return self;
}

- (void)handleResponse:(NSDictionary *)data {
    NSDictionary *payload = data[@"payload"];
    BOOL error = [data[@"error"] boolValue];
    NSString *requestId = payload[@"requestId"];

    //Gets the callback for this request
    ResponseBlock handler = [_requests objectForKey:requestId];

    if (!handler) {
        [ZPCLog warn:@"Unable to find handler for requestId: %@", requestId];
        return;
    }

    //If this is an error response, trigger the callback right away
    if (error) {
        handler(nil, [NSError errorWithDomain:@"Zapic" code:0 userInfo:payload]);
    }

    id response = nil;
    NSString *dataType = payload[@"dataType"];
    id responseData = payload[@"response"];

    if ([dataType isEqualToString:ZPCCompetitionList]) {
        response = [ZPCCompetition decodeCompetitionList:responseData];
    } else if ([dataType isEqualToString:ZPCStatistics]) {
        response = [ZPCStatistic decodeStatistics:responseData];
    }

    //Trigger the callback with the reponse data
    handler(response, nil);
}

- (void)sendQuery:(NSString *)dataType withCompletionHandler:(ResponseBlock)completionHandler {
    //Generate a new unique id
    NSString *requestId = [NSUUID UUID].UUIDString;

    //Save the callback for this request id
    [_requests setObject:completionHandler forKey:requestId];

    NSDictionary *msg = @{
        @"requestId": requestId,
        @"dataType": dataType,
        @"dataTypeVersion": @1
    };

    //Send the query to JS
    [_messageQueue sendMessage:ZPCWebFunctionQuery withPayload:msg];
}

- (void)getCompetitions:(void (^)(NSArray<ZPCCompetition *> *competitions, NSError *error))completionHandler {
    [self sendQuery:ZPCCompetitionList withCompletionHandler:completionHandler];
}

- (void)getStatistics:(void (^)(NSArray<ZPCStatistic *> *statistics, NSError *error))completionHandler {
    [self sendQuery:ZPCStatistics withCompletionHandler:completionHandler];
}

@end
