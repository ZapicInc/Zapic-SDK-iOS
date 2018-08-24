#import "ZPlayer.h"

@implementation ZPlayer
- (instancetype)initWithId:(NSString *)playerId withToken:(NSString *)notificationToken {
    if (self = [super init]) {
        _playerId = playerId;
        _notificationToken = notificationToken;
    }
    return self;
}
@end
