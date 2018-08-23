#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ZAppStatus) {
    ZAppStatusNone,
    ZAppStatusReady,
};

@interface ZAppStatusMessage : NSObject

@property (readonly, nonatomic) ZAppStatus status;

- (instancetype)initWithStatus:(ZAppStatus)status;

@end
