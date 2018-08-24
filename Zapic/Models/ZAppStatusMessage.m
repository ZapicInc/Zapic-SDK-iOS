#import "ZAppStatusMessage.h"

@implementation ZAppStatusMessage

- (instancetype)initWithStatus:(ZAppStatus)status {
    if (self = [super init]) {
        _status = status;
    }
    return self;
}
@end
