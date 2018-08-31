@import Foundation;
#import "ZWebApp.h"

typedef NS_ENUM(NSInteger, ZWebFunction) {
    ZWebFunctionSubmitEvent,
    ZWebFunctionOpenPage,
    ZWebFunctionClosePage,
    ZWebFunctionSetDeviceToken,
    ZWebFunctionNotificationOpened,
    ZWebFunctionNotificationReceived
};

@interface ZMessageQueue : NSObject
@property (nonatomic, strong) ZWebApp *webApp;
- (void)sendMessage:(ZWebFunction)function withPayload:(NSObject *)payload;
- (void)sendMessage:(ZWebFunction)function withPayload:(NSObject *)payload isError:(BOOL)isError;
- (void)sendQueuedMessages;
@end
