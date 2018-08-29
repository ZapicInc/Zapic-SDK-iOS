@import Foundation;
@import UIKit;

@interface ZShareMessage : NSObject
@property (readonly, strong) NSString *text;
@property (readonly, strong) NSURL *url;
@property (readonly, strong) UIImage *image;

- (instancetype)initWithText:(nullable NSString *)text
                   withImage:(nullable UIImage *)image
                     withURL:(nullable NSURL *)url;
@end
