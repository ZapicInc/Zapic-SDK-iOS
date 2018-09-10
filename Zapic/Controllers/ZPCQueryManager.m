#import "ZPCQueryManager.h"
#import "ZPCLog.h"

typedef void (^ResponseBlock)(id response, NSError *error);

@interface ZPCQueryManager ()
@property (readonly) ZPCScriptMessageHandler *messageHandler;
@property (readonly) ZPCMessageQueue *messageQueue;
@property (nonnull, readonly) NSMutableDictionary<NSString *, ResponseBlock> *requests;
@end

@implementation ZPCQueryManager

static NSString *const ZPCCompetitions = @"competitions";
static NSString *const ZPCStatistics = @"statistics";
static NSString *const ZPCChallenges = @"challenges";

static NSString *const ZPCErrorDomain = @"com.Zapic";
static NSInteger const ZPCErrorUnavailable = 2600;
static NSInteger const ZPCErrorClient = 2601;

- (void)setIsReady:(BOOL)isReady {
    if (isReady == _isReady) {
        return;
    }

    _isReady = isReady;

    //If the manager is not available, close all pending queries
    if (!_isReady) {
        [self failAllQueries];
    }
}

- (instancetype)initWithMessageHandler:(ZPCScriptMessageHandler *)messageHandler messageQueue:(ZPCMessageQueue *)messageQueue {
    if (self = [super init]) {
        _messageQueue = messageQueue;
        _messageHandler = messageHandler;
        _requests = [[NSMutableDictionary alloc] init];
        _isReady = YES;

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
        handler(nil, [NSError errorWithDomain:ZPCErrorDomain code:ZPCErrorClient userInfo:@{@"errorMsg": payload}]);
    }

    id response = nil;
    NSString *dataType = payload[@"dataType"];
    id responseData = payload[@"response"];

    if ([dataType isEqualToString:ZPCCompetitions]) {
        response = [ZPCCompetition decodeList:responseData];
    } else if ([dataType isEqualToString:ZPCStatistics]) {
        response = [ZPCStatistic decodeList:responseData];
    } else if ([dataType isEqualToString:ZPCChallenges]) {
        response = [ZPCChallenge decodeList:responseData];
    }

    //Trigger the callback with the reponse data
    handler(response, nil);

    [_requests removeObjectForKey:requestId];
}

- (void)sendQuery:(NSString *)dataType withCompletionHandler:(ResponseBlock)completionHandler {
    //If requests cant be processed now, cancel immediately
    if (!_isReady) {
        NSError *error = [NSError errorWithDomain:ZPCErrorDomain
                                             code:ZPCErrorUnavailable
                                         userInfo:nil];

        completionHandler(nil, error);
        return;
    }

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

- (void)failAllQueries {
    for (NSString *requestId in _requests) {
        NSError *error = [NSError errorWithDomain:ZPCErrorDomain
                                             code:ZPCErrorUnavailable
                                         userInfo:nil];

        //Gets the handler
        ResponseBlock handler = [_requests objectForKey:requestId];

        //Trigger the handler with the error
        handler(nil, error);
    }

    [_requests removeAllObjects];
}

- (void)getCompetitions:(void (^)(NSArray<ZPCCompetition *> *competitions, NSError *error))completionHandler {
    [self sendQuery:ZPCCompetitions withCompletionHandler:completionHandler];
}

- (void)getStatistics:(void (^)(NSArray<ZPCStatistic *> *statistics, NSError *error))completionHandler {
    [self sendQuery:ZPCStatistics withCompletionHandler:completionHandler];
}

- (void)getChallenges:(void (^)(NSArray<ZPCChallenge *> *statistics, NSError *error))completionHandler {
    [self sendQuery:ZPCChallenges withCompletionHandler:completionHandler];
}

@end
