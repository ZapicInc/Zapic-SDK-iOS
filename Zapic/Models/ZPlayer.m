#import "ZPlayer.h"

@implementation ZPlayer
- (instancetype)initWithId:(NSString *)identifier token:(NSString *)notificationToken name:(NSString *)name iconUrl:(NSURL*)iconUrl {
    if (self = [super init]) {
        _identifier = identifier;
        _notificationToken = notificationToken;
        _name = name;
        _iconUrl = iconUrl;
    }
    return self;
}
@end
