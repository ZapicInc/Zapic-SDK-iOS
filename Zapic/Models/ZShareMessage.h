#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZShareMessage : NSObject
@property (readonly, strong) NSString *text;
@property (readonly, strong) NSURL *url;
@property (readonly, strong) UIImage *image;

- (instancetype)initWithText:(nullable NSString *)text
                   withImage:(nullable UIImage *)image
                     withURL:(nullable NSURL *)url;
@end
