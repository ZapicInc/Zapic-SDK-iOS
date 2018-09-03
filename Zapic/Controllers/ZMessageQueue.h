@import Foundation;
#import "ZWebApp.h"

static NSString *const ZWebFunctionSubmitEvent = @"SUBMIT_EVENT";
static NSString *const ZWebFunctionOpenPage = @"OPEN_PAGE";
static NSString *const ZWebFunctionClosePage = @"CLOSE_PAGE";
static NSString *const ZWebFunctionSetDeviceToken = @"DEVICE_TOKEN";
static NSString *const ZWebFunctionNotificationOpened = @"NOTIFICATION_OPENED";
static NSString *const ZWebFunctionNotificationReceived = @"NOTIFICATION_RECEIVED";
static NSString *const ZWebFunctionQuery = @"QUERY";

@interface ZMessageQueue : NSObject
@property (nonatomic, strong) ZWebApp *webApp;
- (void)sendMessage:(NSString *)function withPayload:(NSObject *)payload;
- (void)sendMessage:(NSString *)function withPayload:(NSObject *)payload isError:(BOOL)isError;
- (void)sendQueuedMessages;
@end
