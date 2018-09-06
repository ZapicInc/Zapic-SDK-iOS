#import "ZPCPlayEvent.h"
#import "ZPCChallenge.h"
#import "ZPCCompetition.h"
#import "ZPCLog.h"

@implementation ZPCPlayEvent

- (instancetype)initWithPayload:(NSDictionary *)payload {
    if (self = [super init]) {
        _playType = [self parseType:payload[@"dataType"]];

        switch (_playType) {
            case ZPCPlayTypeChallenge:
                _data = [[ZPCChallenge alloc] initWithData:payload[@"data"]];
                break;
            case ZPCPlayTypeCompetition:
                _data = [[ZPCCompetition alloc] initWithData:payload[@"data"]];
                break;
            default:
                _data = nil;
        }
    }
    return self;
}

- (ZPCPlayType)parseType:(NSString *)string {
    if ([string isEqualToString:@"competition"]) {
        return ZPCPlayTypeCompetition;
    } else if ([string isEqualToString:@"challenge"]) {
        return ZPCPlayTypeChallenge;
    } else {
        [ZPCLog error:@"Unknown play data %@", string];
        return ZPCPlayTypeUnknown;
    }
}

@end
