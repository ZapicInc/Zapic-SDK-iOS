#import <Foundation/Foundation.h>
#import "ZMessageQueue.h"

@interface ZNotificationManager : NSObject
- (instancetype)initWithMessageQueue:(ZMessageQueue *)messageQueue;
- (void)registerForPushNotifications;
- (void)setDeviceToken:(NSData *)deviceToken;
- (void)setDeviceTokenError:(NSError *)error;
- (void)receivedNotification:(NSDictionary *)userInfo;
@end
