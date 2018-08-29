@import Foundation;
#import "ZWebApp.h"

typedef NS_ENUM(NSInteger, ZWebFunction) {
    ZWebFunctionSubmitEvent,
    ZWebFunctionOpenPage,
    ZWebFunctionClosePage,
};

@interface ZMessageQueue : NSObject
@property (nonatomic, strong) ZWebApp *webApp;
- (void)sendMessage:(ZWebFunction)function withPayload:(NSObject *)payload;
- (void)sendQueuedMessages;
@end
