#import <Foundation/Foundation.h>
#import <UIKit/UIKIt.h>

@interface ZImageUtils : NSObject
+ (UIImage *)getZapicLogo;
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;
@end
