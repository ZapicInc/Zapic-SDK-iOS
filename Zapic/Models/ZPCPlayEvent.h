#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZPCPlayType) {
    ZPCPlayTypeUnknown,
    ZPCPlayTypeChallenge,
    ZPCPlayTypeCompetition,
};

@interface ZPCPlayEvent : NSObject

/**
 The type of Zapic feature
 */
@property (readonly) ZPCPlayType playType;

/**
 The developer defined metdata.
 */
@property (readonly) id data;

/**
 Creates a new play event from the JS payload

 @param payload The payload
 @return The new play event
 */
- (instancetype)initWithPayload:(NSDictionary *)payload;

@end
