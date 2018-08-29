@import UIKit;
#import "ZWebViewController.h"

@interface ZBaseView : UIView
@property (weak) ZWebViewController *viewController;
- (instancetype)initWithSpinner;
- (instancetype)initWithText:(NSString *)text subText:(NSString *)subText showSpinner:(BOOL)showSpinner;
@end
