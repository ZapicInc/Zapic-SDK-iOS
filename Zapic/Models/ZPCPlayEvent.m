#import "ZPCPlayEvent.h"

@implementation ZPCPlayEvent

- (instancetype)initWithPayload:(NSDictionary *)payload {
    if (self = [super init]) {
        _dataType = payload[@"type"];
        _metadata = payload[@"metadata"];
    }
    return self;
}

@end
