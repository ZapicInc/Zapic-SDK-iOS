#import "ZWebViewController.h"
#import "ZBannerManager.h"
#import "ZErrorView.h"
#import "ZLoadingView.h"
#import "ZLog.h"
#import "ZMessageQueue.h"
#import "ZSafariManager.h"
#import "ZShareManager.h"
#import "ZUtils.h"

@interface ZWebViewController ()
@property BOOL isVisible;
@property BOOL pageReady;
@property (readonly) ZErrorView *errorView;
@property (readonly) ZLoadingView *loadingView;
@property (readonly, strong) ZBannerManager *bannerManager;
@property (readonly, strong) ZSafariManager *safariManager;
@property (readonly, strong) ZShareManager *shareManager;
@property (readonly, strong) ZScriptMessageHandler *messageHandler;
@property (readonly, strong) ZMessageQueue *messageQueue;
@property (nonatomic, strong) ZBackgroundView *backgroundView;
@property (nonatomic, strong) ZWebApp *webApp;
@end

@implementation ZWebViewController

- (instancetype)init {
    if (self = [super init]) {
        //Bootstrap the required frameworks
        [ZUtils loadSafariServices];
        [ZUtils loadWebKit];

        _safariManager = [[ZSafariManager alloc] initWithController:self];
        _shareManager = [[ZShareManager alloc] initWithController:self];

        //Initialize the background view that will hold onto the webview
        _backgroundView = [[ZBackgroundView alloc] init];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [_backgroundView placeViewToBackground];

        _messageHandler = [[ZScriptMessageHandler alloc] init];
        _messageQueue = [[ZMessageQueue alloc] init];

        //Initialize the loading view
        _loadingView = [[ZLoadingView alloc] init];
        _loadingView.viewController = self;

        //Initialize the error view
        _errorView = [[ZErrorView alloc] init];
        _errorView.viewController = self;

        //Initialize the web app
        _webApp = [[ZWebApp alloc] initWithHandler:_messageHandler];
        _webApp.safariManager = _safariManager;
        [_backgroundView addSubview:_webApp];

        _messageQueue.webApp = _webApp;

        //Setup the banners
        _bannerManager = [[ZBannerManager alloc] init];
        _bannerManager.messageHandler = _messageHandler;

        _playerManager = [[ZPlayerManager alloc] initWithHandler:_messageHandler];

        __weak ZWebViewController *weakSelf = self;

        [_messageHandler addAppStatusHandler:^(ZAppStatusMessage *msg) {
            if (msg.status == ZAppStatusReady) {
                [weakSelf.messageQueue sendQueuedMessages];
                self->_pageReady = YES;
            }
        }];

        [_messageHandler addClosePageHandler:^{
            [weakSelf closePage];
        }];

        [_messageHandler addPageReadyHandler:^{
            weakSelf.view = weakSelf.webApp;
        }];

        [_messageHandler addShowPageHandler:^{
            [weakSelf showPage:@"current"];
        }];

        [_messageHandler addShowShareHandler:^(ZShareMessage *msg) {
            [weakSelf.shareManager share:msg];
        }];

        _webApp.loadErrorHandler = ^{
            weakSelf.view = weakSelf.errorView;
        };

        //Start loading the Zapic web app
        [_webApp loadUrl:@"https://app.zapic.net"];
    }
    return self;
}

- (void)closePage {
    [super dismissViewControllerAnimated:YES
                              completion:^{
                                  [self->_messageQueue sendMessage:ZWebFunctionClosePage withPayload:@""];
                                  [self->_backgroundView addSubview:self->_webApp];
                              }];
    _isVisible = false;
}

- (void)showPage:(NSString *)pageName {
    [ZLog info:@"Showing %@ page", pageName];

    if (_pageReady) {
        self.view = _webApp;
    } else if (_webApp.errorLoading) {
        self.view = _errorView;
    } else {
        self.view = _loadingView;
    }

    //Trigger the web to update
    [_messageQueue sendMessage:ZWebFunctionOpenPage withPayload:pageName];

    if (_isVisible) {
        [ZLog info:@"Zapic already visible"];
        return;
    }

    _isVisible = true;

    [self.view.topAnchor constraintEqualToAnchor:self.topLayoutGuide.topAnchor].active = YES;
    [self.view.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.bottomAnchor].active = YES;

    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;

    UIViewController *root = [ZUtils getTopViewController];
    [root presentViewController:self animated:true completion:nil];
}

- (void)submitEvent:(ZEventType)eventType withPayload:(NSObject *)payload {
    [ZLog info:@"Submitting an event to the web client"];

    NSDictionary *msg = @{
        @"type": [ZWebViewController getEventTypeName:eventType],
        @"params": payload,
        @"timestamp": [ZUtils getIsoNow],
    };

    [_messageQueue sendMessage:ZWebFunctionSubmitEvent withPayload:msg];
}

+ (NSString *)getEventTypeName:(ZEventType)eventType {
    if (eventType == ZEventTypeGameplay) {
        return @"gameplay";
    } else if (eventType == ZEventTypeInteraction) {
        return @"interaction";
    } else {
        [ZLog error:@"Unknow event type"];
        return @"";
    }
}

@end
