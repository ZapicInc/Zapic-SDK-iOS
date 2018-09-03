#import "ZPCShareMessage.h"

@implementation ZPCShareMessage

- (instancetype)initWithText:(nullable NSString *)text
                   withImage:(nullable UIImage *)image
                     withURL:(nullable NSURL *)url {
    if (self = [super init]) {
        _text = text;
        _image = image;
        _url = url;
    }
    return self;
}
@end
