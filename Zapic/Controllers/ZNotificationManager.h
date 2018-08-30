#import <Foundation/Foundation.h>
#import "ZMessageQueue.h"
@interface ZNotificationManager : NSObject

@property (class) ZMessageQueue *messageQueue;
/**
 Attempts to register the device for push notifications.
 */
+ (void)registerForPushNotifications;

+ (void)setDeviceToken:(NSData *)deviceToken;
+ (void)setDeviceTokenError:(NSString *)error;

+ (void)receivedNotification:(UIApplication *)application notificationInfo:(NSDictionary *)userInfo;

@end
