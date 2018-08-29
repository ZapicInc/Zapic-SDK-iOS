@import UIKit;
#import "ZSafariManager.h"
#import "ZScriptMessageHandler.h"

@import WebKit;

@interface ZWebApp : UIView <UIScrollViewDelegate, WKNavigationDelegate>
@property ZSafariManager *safariManager;
@property (readonly) BOOL errorLoading;
/**
 The handler when a player logs in to Zapic.
 */
@property (nonatomic, copy, nullable) void (^loadErrorHandler)(void);
- (instancetype)initWithHandler:(nonnull ZScriptMessageHandler *)messageHandler;
- (void)loadUrl:(NSString *)url;
- (void)evaluateJavaScript:(NSString *)jsString;
@end
