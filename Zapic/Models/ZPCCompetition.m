#import "ZPCCompetition.h"
#import "ZPCUtils.h"

@implementation ZPCCompetition

- (instancetype)initWithId:(nonnull NSString *)identifier
                     title:(nullable NSString *)title
                      text:(nullable NSString *)text
                  metadata:(nullable NSString *)metadata
                    active:(BOOL)active
                     start:(nullable NSDate *)start
                       end:(nullable NSDate *)end
                totalUsers:(nullable NSNumber *)totalUsers
                    status:(nullable NSString *)status
            formattedScore:(nullable NSString *)formattedScore
                     score:(nullable NSNumber *)score
           leaderboardRank:(nullable NSNumber *)leaderboardRank
                leagueRank:(nullable NSNumber *)leagueRank {
    if (self = [super init]) {
        _identifier = identifier;
        _title = title;
        _text = text;
        _metadata = metadata;
        _active = active;
        _start = start;
        _end = end;
        _totalUsers = totalUsers;
        _status = status;
        _formattedScore = formattedScore;
        _score = score;
        _leaderboardRank = leaderboardRank;
        _leagueRank = leagueRank;
    }
    return self;
}

+ (NSArray<ZPCCompetition *> *)decodeCompetitionList:(NSArray<NSDictionary *> *)data {
    NSMutableArray<ZPCCompetition *> *competitions = [NSMutableArray arrayWithCapacity:data.count];

    for (id compData in data) {
        ZPCCompetition *competition = [ZPCCompetition decodeCompetition:compData];
        [competitions addObject:competition];
    }

    return competitions;
}

+ (ZPCCompetition *)decodeCompetition:(NSDictionary *)data {
    return [[ZPCCompetition alloc] initWithId:data[@"id"]
                                        title:data[@"title"]
                                         text:data[@"description"]
                                     metadata:data[@"metadata"]
                                       active:[data[@"active"] boolValue]
                                        start:[ZPCUtils parseDateIso:data[@"start"]]
                                          end:[ZPCUtils parseDateIso:data[@"end"]]
                                   totalUsers:@([data[@"totalUsers"] longValue])
                                       status:data[@"status"]
                               formattedScore:data[@"formattedScore"]
                                        score:@([data[@"score"] doubleValue])
                              leaderboardRank:@([data[@"leaderboardRank"] longValue])
                                   leagueRank:@([data[@"leagueRank"] longValue])];
}

@end
