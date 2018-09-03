@import Foundation;
@import UIKit;

@interface ZUtils : NSObject
+ (UIViewController *)getTopViewController;
+ (UIView *)getTopView;
+ (NSString *)getIsoNow;
+ (NSDate *)parseDateIso:(NSString *)dateString;
@end
