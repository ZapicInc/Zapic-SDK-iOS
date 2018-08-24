#import "ZBannerMessage.h"

@implementation ZBannerMessage

- (instancetype)initWithTitle:(NSString *)title
                 withSubtitle:(nonnull NSString *)subtitle
                     withData:(nonnull NSString *)data
                     withIcon:(nonnull UIImage *)icon {
    if (self = [super init]) {
        _title = title;
        _subtitle = subtitle;
        _data = data;
        _icon = icon;
    }
    return self;
}

+ (instancetype)bannerWithTitle:(nonnull NSString *)title
                   withSubtitle:(nonnull NSString *)subtitle
                       withData:(nonnull NSString *)data
                       withIcon:(nonnull UIImage *)icon {
    ZBannerMessage *message = [[ZBannerMessage alloc] initWithTitle:title
                                                       withSubtitle:subtitle
                                                           withData:data
                                                           withIcon:icon];

    return message;
}

@end
