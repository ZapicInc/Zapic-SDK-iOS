@import Foundation;
@import UIKit;

@interface ZPCUtils : NSObject
+ (UIViewController *)getTopViewController;
+ (UIView *)getTopView;
+ (NSString *)getIsoNow;
+ (NSDate *)parseDateIso:(NSString *)dateString;
@end
