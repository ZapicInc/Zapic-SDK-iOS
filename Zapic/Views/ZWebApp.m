#import "ZWebApp.h"
#import <SafariServices/SafariServices.h>
#import "ZInjectedJS.h"
#import "ZLog.h"
#import "ZUtils.h"

@interface ZWebApp ()

@property (nonatomic, strong) NSString *appUrl;
@property (nonatomic, assign) bool loadSuccessful;
@property (nonatomic, assign) int retryAttempt;
@property (readonly) UIView *webView;
@property (nonatomic, assign) SEL evaluateJavaScriptSelector;
@property (nonatomic, assign) void (*evaluateJavaScriptFunc)(id, SEL, NSString *, id);

@end

@implementation ZWebApp

- (instancetype)initWithHandler:(nonnull ZScriptMessageHandler *)messageHandler {
    if (self = [super initWithFrame:CGRectZero]) {
        id config = [ZWebApp getWebViewConfiguration];
        if (config) {
            config = [ZUtils addUserContentControllerMessageHandlers:config delegate:messageHandler handledMessages:@[ScriptMethodName]];

            if (!config) {
                return nil;
            }
        } else {
            return nil;
        }

        _webView = [ZUtils initWebView:@"WKWebView" frame:CGRectZero configuration:config];

        if (_webView == NULL) {
            return nil;
        }

        [ZLog info:@"Got WebView"];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.opaque = NO;
        _webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        [_webView setValue:@NO forKeyPath:@"scrollView.scrollEnabled"];
        [_webView setValue:@NO forKeyPath:@"scrollView.bounces"];
        [_webView setValue:self forKeyPath:@"scrollView.delegate"];

        //Sets the navigation delegate
        SEL setNavigationDelegateSel = NSSelectorFromString(@"setNavigationDelegate:");

        if ([_webView respondsToSelector:setNavigationDelegateSel]) {
            IMP setNavigationDelegateImp = [_webView methodForSelector:setNavigationDelegateSel];
            if (setNavigationDelegateImp) {
                void (*setNavigationDelegateFunc)(id, SEL, id) = (void *)setNavigationDelegateImp;
                setNavigationDelegateFunc(_webView, setNavigationDelegateSel, self);
            }
        }

        //Gets the evaluateJavaScript method for the webview
        _evaluateJavaScriptSelector = NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
        if ([_webView respondsToSelector:_evaluateJavaScriptSelector]) {
            IMP evaluateJavaScriptImp = [_webView methodForSelector:_evaluateJavaScriptSelector];
            if (evaluateJavaScriptImp) {
                _evaluateJavaScriptFunc = (void *)evaluateJavaScriptImp;
                [ZLog info:@"Cached selector and function for evaluateJavaScript"];
            } else {
                return nil;
            }
        } else {
            return nil;
        }

        [self addSubview:_webView];
        [_webView.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [_webView.leftAnchor constraintEqualToAnchor:self.leftAnchor].active = YES;
        [_webView.rightAnchor constraintEqualToAnchor:self.rightAnchor].active = YES;
        [_webView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
    }
    return self;
}

- (void)evaluateJavaScript:(NSString *)jsString {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ZLog info:@"Dispatching %@", jsString];

        if (self.webView && self.evaluateJavaScriptFunc && self.evaluateJavaScriptSelector) {
            self.evaluateJavaScriptFunc(self.webView, self.evaluateJavaScriptSelector, jsString, nil);
        }
    });
}

- (void)loadUrl:(NSString *)url {
    _appUrl = url;
    [self load];
}

- (void)load {
    NSURLRequest *appRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_appUrl]];

    SEL loadFileUrlSelector = NSSelectorFromString(@"loadRequest:");
    if ([_webView respondsToSelector:loadFileUrlSelector]) {
        [ZLog info:@"WebView responds to loadFileURL selector"];
        IMP loadFileUrlImp = [_webView methodForSelector:loadFileUrlSelector];
        if (loadFileUrlImp) {
            [ZLog info:@"Got loadFileURL implementation: %@", _appUrl];
            void (*loadFileUrlFunc)(id, SEL, NSURLRequest *) = (void *)loadFileUrlImp;
            loadFileUrlFunc(_webView, loadFileUrlSelector, appRequest);
        }
    }
}

+ (id)getWebViewConfiguration {
    id config = [ZUtils getObjectFromClass:@"WKWebViewConfiguration"];

    //Gets the info to be injected
    NSString *sdkVersion = ([NSBundle bundleForClass:[self class]].infoDictionary)[@"CFBundleShortVersionString"];
    NSString *bundleId = NSBundle.mainBundle.bundleIdentifier;
    NSString *iosVersion = UIDevice.currentDevice.systemVersion;

    //Gets the JS code to be injected
    NSString *injected = [ZInjectedJS getInjectedScript:iosVersion bundleId:bundleId sdkVersion:sdkVersion];

    id script;

    id userScriptClass = NSClassFromString(@"WKUserScript");
    if (userScriptClass) {
        id userScriptAlloc = [userScriptClass alloc];
        SEL initSelector = NSSelectorFromString(@"initWithSource:injectionTime:forMainFrameOnly:");
        if ([userScriptAlloc respondsToSelector:initSelector]) {
            [ZLog info:@"WKUserScript responds to init selector"];
            IMP initImp = [userScriptAlloc methodForSelector:initSelector];
            if (initImp) {
                [ZLog info:@"Got init implementation"];
                id (*initFunc)(id, SEL, NSString *, id, BOOL) = (void *)initImp;
                script = initFunc(userScriptAlloc, initSelector, injected, 0, YES);
            }
        }
    }

    config = [ZUtils addWKUserScript:config script:script];

    return config;
}

- (void)retryAfterDelay {
    if (_loadSuccessful) {
        return;
    }

    _retryAttempt += 1;

    static CGFloat const base = 5;
    static CGFloat const maxDelay = 300; //5 minutes

    //Calculate the delay before the next retry
    float delay = MAX(1, drand48() * MIN(maxDelay, base * pow(2.0, _retryAttempt)));

    [ZLog info:@"Will try to reload in %f sec", delay];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self load];
    });
}

#pragma mark - WKNavigationDelegate

- (void)webView:(id)webView didFinishNavigation:(id)navigation {
    [ZLog info:@"Finished loading web app"];
    _retryAttempt = 0;
    _loadSuccessful = YES;
    _errorLoading = NO;
}

/**
   Handles any errors loading the web view
   
   @param webView The web view invoking the delegate method.
   @param navigation The navigation object that started to load a page.
   @param error The error that occurred.
   */
- (void)webView:(id)webView didFailProvisionalNavigation:(id)navigation withError:(NSError *)error {
    if ([error.domain isEqual:@"WebKitErrorDomain"] && error.code == 102) {
        [ZLog info:@"Skipping known error message loading url"];
        return;
    }

    [ZLog warn:@"Error loading Zapic webview"];

    [self retryAfterDelay];

    _errorLoading = YES;

    if (_loadErrorHandler) {
        _loadErrorHandler();
    }
}

- (void)webView:(id)webView decidePolicyForNavigationAction:(id)navigationAction decisionHandler:(void (^)(int))decisionHandler {
    NSURL *url = [navigationAction valueForKeyPath:@"request.URL"];

    int const cancel = 0;
    int const allow = 1;

    //Skip if there is not a valid url
    if (!url) {
        decisionHandler(cancel);
        return;
    }

    //Skip if the app has not loaded yet
    if (!_appUrl) {
        decisionHandler(cancel);
        return;
    }

    //Allow the webview to open other links that are within our web app.
    if ([url.absoluteString hasPrefix:_appUrl]) {
        decisionHandler(allow);
        return;
    }
    NSString *scheme = url.scheme;

    if (!scheme) {
        decisionHandler(cancel);
        return;
    }

    //Allow the OS to open the itms links directly into the app store
    if ([scheme hasPrefix:@"itms"]) {
        [UIApplication.sharedApplication openURL:url];
        decisionHandler(cancel);
        return;
    }

    //Opens the a safari view with the content
    [_safariManager openUrl:url];

    //Tell the webview not to open the link
    decisionHandler(cancel);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    scrollView.pinchGestureRecognizer.enabled = NO;
    scrollView.panGestureRecognizer.enabled = NO;
    [scrollView setZoomScale:1.0 animated:NO];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale == 1) {
        return;
    }
    [scrollView setZoomScale:1.0 animated:NO];
}
@end
