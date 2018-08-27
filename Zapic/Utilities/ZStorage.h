@import Foundation;

@interface ZStorage : NSObject
- (void)store:(NSArray<NSString *> *)objects;
- (NSArray<NSString *> *)retrieve;
- (void)clear;
@end
