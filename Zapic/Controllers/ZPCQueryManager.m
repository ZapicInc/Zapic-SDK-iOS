#import "ZPCQueryManager.h"
#import "ZLog.h"

typedef void (^ResponseBlock)(id response, NSError *error);

@interface ZPCQueryManager ()
@property (readonly) ZScriptMessageHandler *messageHandler;
@property (readonly) ZMessageQueue *messageQueue;
@property (nonnull, readonly) NSMutableDictionary<NSString *, ResponseBlock> *requests;
@end
@implementation ZPCQueryManager

static NSString *const ZPCCompetitionList = @"competitionList";

- (instancetype)initWithMessageHandler:(ZScriptMessageHandler *)messageHandler messageQueue:(ZMessageQueue *)messageQueue {
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
        [ZLog warn:@"Unable to find handler for requestId: %@", requestId];
        return;
    }

    //If this is an error response, trigger the callback right away
    if (error) {
        handler(nil, [NSError errorWithDomain:@"Zapic" code:0 userInfo:payload]);
    }

    id response = nil;
    NSString *dataType = payload[@"dataType"];

    if ([dataType isEqualToString:ZPCCompetitionList]) {
        response = [ZPCCompetition decodeCompetitionList:payload[@"response"]];
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
    [_messageQueue sendMessage:ZWebFunctionQuery withPayload:msg];
}

- (void)getCompetitions:(void (^)(NSArray<ZPCCompetition *> *competitions, NSError *error))completionHandler {
    [self sendQuery:ZPCCompetitionList withCompletionHandler:completionHandler];
}

@end
