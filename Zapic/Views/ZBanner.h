@import Foundation;
@import UIKit;

@interface ZBanner : UIView

@property (nonatomic, copy) void (^callback)(void);

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image;
- (void)show:(NSTimeInterval)duration;

@end
