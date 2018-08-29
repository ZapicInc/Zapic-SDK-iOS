@import Foundation;

@interface ZInjectedJS : NSObject
+ (NSString *)getInjectedScript:(NSString *)iosVersion bundleId:(NSString *)bundleId sdkVersion:(NSString *)sdkVersion;
@end
