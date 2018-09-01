#import "ZScriptMessageHandler.h"
#import "ZLog.h"

@interface ZScriptMessageHandler ()

@property (nonatomic, strong) NSMutableArray<void (^)(ZBannerMessage *)> *bannerHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(ZAppStatusMessage *)> *statusHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(ZPlayer *)> *loginHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(void)> *logoutHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(void)> *closePageHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(void)> *pageReadyHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(void)> *showPageHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(ZShareMessage *)> *showShareHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(NSDictionary *)> *queryResponseHandlers;
@end

@implementation ZScriptMessageHandler

static NSString *const AppStarted = @"APP_STARTED";
static NSString *const ShowBanner = @"SHOW_BANNER";
static NSString *const ShowPage = @"SHOW_PAGE";
static NSString *const ShowShare = @"SHOW_SHARE_MENU";
static NSString *const PageReady = @"PAGE_READY";
static NSString *const ClosePageRequest = @"CLOSE_PAGE_REQUESTED";
static NSString *const LoggedIn = @"LOGGED_IN";
static NSString *const LoggedOut = @"LOGGED_OUT";
static NSString *const QueryResponse = @"QUERY_RESPONSE";

- (instancetype)init {
    if (self = [super init]) {
        _bannerHandlers = [[NSMutableArray<void (^)(ZBannerMessage *)> alloc] init];
        _statusHandlers = [[NSMutableArray<void (^)(ZAppStatusMessage *)> alloc] init];
        _loginHandlers = [[NSMutableArray<void (^)(ZPlayer *)> alloc] init];
        _logoutHandlers = [[NSMutableArray<void (^)(void)> alloc] init];
        _closePageHandlers = [[NSMutableArray<void (^)(void)> alloc] init];
        _pageReadyHandlers = [[NSMutableArray<void (^)(void)> alloc] init];
        _showPageHandlers = [[NSMutableArray<void (^)(void)> alloc] init];
        _showShareHandlers = [[NSMutableArray<void (^)(ZShareMessage *)> alloc] init];
        _queryResponseHandlers = [[NSMutableArray<void (^)(NSDictionary *)> alloc] init];
    }
    return self;
}

- (void)userContentController:(id)userContentController didReceiveScriptMessage:(id)message {
    NSString *name = [message valueForKey:@"name"];
    if (![name isEqualToString:ScriptMethodName]) {
        [ZLog warn:@"Received unknown method from JS"];
        return;
    }

    NSDictionary *json = [message valueForKey:@"body"];

    if (json == nil || ![json isKindOfClass:[NSDictionary class]]) {
        [ZLog warn:@"Received invalid message format"];
        return;
    }

    NSString *type = [json valueForKey:@"type"];

    if (!type.length) {
        [ZLog warn:@"Received a message with a missing message type"];
        return;
    }

    [self handleMessage:type withData:json];
}

- (void)addAppStatusHandler:(void (^)(ZAppStatusMessage *))handler {
    [_statusHandlers addObject:handler];
}

- (void)addBannerHandler:(void (^)(ZBannerMessage *))handler {
    [_bannerHandlers addObject:handler];
}

- (void)addClosePageHandler:(void (^)(void))handler {
    [_closePageHandlers addObject:handler];
}

- (void)addPageReadyHandler:(void (^)(void))handler {
    [_pageReadyHandlers addObject:handler];
}

- (void)addLoginHandler:(void (^)(ZPlayer *))handler {
    [_loginHandlers addObject:handler];
}

- (void)addLogoutHandler:(void (^)(void))handler {
    [_logoutHandlers addObject:handler];
}

- (void)addShowPageHandler:(void (^)(void))handler {
    [_showPageHandlers addObject:handler];
}

- (void)addShowShareHandler:(void (^)(ZShareMessage *))handler {
    [_showShareHandlers addObject:handler];
}

- (void)addQueryResponseHandler:(void (^)(NSDictionary *))handler {
    [_queryResponseHandlers addObject:handler];
}

- (void)handleMessage:(nonnull NSString *)type
             withData:(nonnull NSDictionary *)data {
    [ZLog info:@"Received %@ from JS", type];

    if ([type isEqualToString:AppStarted]) {
        [self handleStatusUpdated:ZAppStatusReady];
    } else if ([type isEqualToString:ClosePageRequest]) {
        [self handleClosePageRequested];
    } else if ([type isEqualToString:LoggedIn]) {
        [self handleLogin:data];
    } else if ([type isEqualToString:LoggedOut]) {
        [self handleLogout];
    } else if ([type isEqualToString:PageReady]) {
        [self handlePageReady];
    } else if ([type isEqualToString:ShowBanner]) {
        [self handleBanner:data];
    } else if ([type isEqualToString:ShowPage]) {
        [self handleShowPage];
    } else if ([type isEqualToString:ShowShare]) {
        [self handleShowShare:data];
    } else if ([type isEqualToString:QueryResponse]) {
        [self handleQueryResponse:data];
    } else {
        [ZLog info:@"Recevied unhandled message type: %@", type];
    }
}

- (void)handleBanner:(nonnull NSDictionary *)data {
    NSDictionary *msg = data[@"payload"];
    NSString *title = msg[@"title"];
    NSString *subtitle = msg[@"subtitle"];
    NSString *metadata = msg[@"data"];
    UIImage *img = [self decodeBase64ToImage:msg[@"icon"]];

    ZBannerMessage *bannerMessage = [ZBannerMessage bannerWithTitle:title withSubtitle:subtitle withData:metadata withIcon:img];

    for (id (^handler)(ZBannerMessage *) in _bannerHandlers) {
        handler(bannerMessage);
    }
}

- (void)handleShowPage {
    for (id (^handler)(void) in _showPageHandlers) {
        handler();
    }
}

- (void)handleShowShare:(nonnull NSDictionary *)data {
    NSDictionary *msg = data[@"payload"];
    NSString *text = msg[@"text"];
    NSString *urlStr = msg[@"url"];
    NSString *imgStr = msg[@"image"];

    NSURL *url;
    UIImage *img;

    if (urlStr && urlStr != (id)[NSNull null]) {
        url = [NSURL URLWithString:urlStr];
    }

    if (imgStr) {
        img = [self decodeBase64ToImage:imgStr];
    }

    ZShareMessage *shareMsg = [[ZShareMessage alloc] initWithText:text withImage:img withURL:url];

    for (id (^handler)(ZShareMessage *) in _showShareHandlers) {
        handler(shareMsg);
    }
}

- (void)handleLogin:(nonnull NSDictionary *)data {
    NSDictionary *msg = data[@"payload"];
    NSString *userId = msg[@"userId"];
    NSString *notificationToken = msg[@"notificationToken"];

    ZPlayer *player = [[ZPlayer alloc] initWithId:userId withToken:notificationToken];

    for (id (^handler)(ZPlayer *) in _loginHandlers) {
        handler(player);
    }
}

- (void)handleLogout {
    for (id (^handler)(void) in _logoutHandlers) {
        handler();
    }
}

- (void)handleStatusUpdated:(ZAppStatus)status {
    ZAppStatusMessage *statusMessage = [[ZAppStatusMessage alloc] initWithStatus:status];

    for (id (^handler)(ZAppStatusMessage *) in _statusHandlers) {
        handler(statusMessage);
    }
}

- (void)handleClosePageRequested {
    for (id (^handler)(void) in _closePageHandlers) {
        handler();
    }
}

- (void)handlePageReady {
    for (id (^handler)(void) in _pageReadyHandlers) {
        handler();
    }
}

- (void)handleQueryResponse:(nonnull NSDictionary *)data {
    for (id (^handler)(NSDictionary *) in _queryResponseHandlers) {
        handler(data);
    }
}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    if (!strEncodeData.length) {
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

@end
