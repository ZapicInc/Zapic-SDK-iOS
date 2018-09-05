#import <Foundation/Foundation.h>

static NSString *const ZPCCompetitionStatusInvited = @"invited";
static NSString *const ZPCCompetitionStatusIgnored = @"ignored";
static NSString *const ZPCCompetitionStatusAccepted = @"accepted";

@interface ZPCCompetition : NSObject

#pragma mark - Competition Definition

/**
 The unique id for the competition.
 */
@property (nonnull, readonly) NSString *identifier;

/**
 The title for the competition.
 */
@property (nullable, readonly) NSString *title;

/**
 The description for the competition.
 */
@property (nullable, readonly) NSString *text;

/**
 The developer defined metadata for this competition.
 */
@property (nullable, readonly) NSString *metadata;

/**
 Flag indicating if the competition is currently active.
 */
@property (readonly) BOOL active;

/**
 When the competition starts.
 */
@property (nullable, readonly) NSDate *start;

/**
 When the competition ends.
 */
@property (nullable, readonly) NSDate *end;

/**
 The total number of users that have joined the competition.
 */
@property (nullable, readonly) NSNumber *totalUsers;

#pragma mark - Player data

/**
 The current player's score, formatted as defined in the portal.
 */
@property (nullable, readonly) NSString *status;

/**
 The current player's score, formatted as defined in the portal.
 */
@property (nullable, readonly) NSString *formattedScore;

/**
 The current player's score.
 */
@property (nullable, readonly) NSNumber *score;

/**
 The player's rank on the leaderboard (ex. Top 100). If the player
 is not on the leaderboard this value will be nil.
 */
@property (nullable, readonly) NSNumber *leaderboardRank;

/**
 The player's rank in their league. If the player
 is not in a league yet this value will be nil.
 */
@property (nullable, readonly) NSNumber *leagueRank;

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
                leagueRank:(nullable NSNumber *)leagueRank;

/**
 Decodes a collection of competitions

 @param data Array of competition data
 @return Array of competitions
 */
+ (NSArray<ZPCCompetition *> *)decodeCompetitionList:(NSArray<NSDictionary *> *)data;

/**
 Decodes a single competition

 @param data Competition data
 @return The competition
 */
+ (ZPCCompetition *)decodeCompetition:(NSDictionary *)data;
@end
