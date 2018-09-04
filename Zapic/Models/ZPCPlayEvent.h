#import <Foundation/Foundation.h>

@interface ZPCPlayEvent : NSObject

/**
 The type of Zapic feature (ex. "challenge", "competition"...)
 */
@property (nonnull, readonly) NSString *dataType;

/**
 The developer defined metdata.
 */
@property (nullable, readonly) NSString *metadata;

/**
 Creates a new play event from the JS payload

 @param payload The payload
 @return The new play event
 */
- (instancetype)initWithPayload:(NSDictionary *)payload;

@end
