@import UIKit;
#import "ZPCWebViewController.h"

@interface ZPCBaseView : UIView
@property (weak) ZPCWebViewController *viewController;
- (instancetype)initWithSpinner;
- (instancetype)initWithText:(NSString *)text subText:(NSString *)subText showSpinner:(BOOL)showSpinner;
@end
