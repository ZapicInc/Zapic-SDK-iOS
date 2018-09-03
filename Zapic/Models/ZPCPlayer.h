@import Foundation;

@interface ZPCPlayer : NSObject
@property (readonly) NSString *identifier;
@property (readonly) NSString *notificationToken;
@property (readonly) NSString *name;
@property (readonly) NSURL *iconUrl;
- (instancetype)initWithId:(NSString *)identifier token:(NSString *)notificationToken name:(NSString *)name iconUrl:(NSURL *)iconUrl;
@end
