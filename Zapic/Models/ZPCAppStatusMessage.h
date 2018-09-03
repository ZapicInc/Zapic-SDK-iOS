@import Foundation;

typedef NS_ENUM(NSInteger, ZPCAppStatus) {
    ZPCAppStatusNone,
    ZPCAppStatusReady,
};

@interface ZPCAppStatusMessage : NSObject

@property (readonly, nonatomic) ZPCAppStatus status;

- (instancetype)initWithStatus:(ZPCAppStatus)status;

@end
