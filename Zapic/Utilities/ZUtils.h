#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZUtils : NSObject
+ (UIViewController *)getTopViewController;
+ (UIView *)getTopView;
+ (NSString *)getIsoNow;
+ (void)loadWebKit;
+ (void)loadSafariServices;
+ (id)getObjectFromClass:(NSString *)className;
+ (id)addUserContentControllerMessageHandlers:(id)wkConfiguration delegate:(id)delegate handledMessages:(NSArray *)handledMessages;
+ (id)addWKUserScript:(id)wkConfiguration script:(id)wkUserScript;
+ (id)initWebView:(NSString *)className frame:(CGRect)frame configuration:(id)configuration;
@end
