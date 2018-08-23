#import <Foundation/Foundation.h>

@interface ZStorage : NSObject
- (void)store:(NSArray<NSString *> *)objects;
- (NSArray<NSString *> *)retrieve;
- (void)clear;
@end
