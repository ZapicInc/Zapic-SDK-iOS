#import <Foundation/Foundation.h>

@interface ZPlayer : NSObject
@property (readonly) NSString *playerId;
@property (readonly) NSString *notificationToken;
- (instancetype)initWithId:(NSString *)playerId withToken:(NSString *)notificationToken;
@end
