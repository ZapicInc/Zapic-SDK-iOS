#import "ZPCStatistic.h"

@implementation ZPCStatistic

- (instancetype)initWithData:(nonnull NSDictionary *)data {
    if (self = [super init]) {
        _identifier = data[@"id"];
        _title = data[@"title"];
        _formattedScore = data[@"formattedScore"];
        _score = @([data[@"totalUsers"] doubleValue]);
        _rank = @([data[@"rank"] longValue]);
        _percentile = @([data[@"totalUsers"] floatValue]);
    }
    return self;
}

+ (NSArray<ZPCStatistic *> *)decodeStatistics:(nonnull NSArray *)data {
    NSMutableArray<ZPCStatistic *> *stats = [NSMutableArray arrayWithCapacity:data.count];

    for (id compData in data) {
        ZPCStatistic *stat = [[ZPCStatistic alloc] initWithData:compData];
        [stats addObject:stat];
    }

    return stats;
}

@end
