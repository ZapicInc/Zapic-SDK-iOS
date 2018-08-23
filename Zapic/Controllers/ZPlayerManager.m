#import "ZPlayerManager.h"

@interface ZPlayerManager ()
@property (nonatomic, strong) NSMutableArray<void (^)(ZPlayer *)> *loginHandlers;
@property (nonatomic, strong) NSMutableArray<void (^)(ZPlayer *)> *logoutHandlers;
@end

@implementation ZPlayerManager

- (instancetype)initWithHandler:(ZScriptMessageHandler *)handler {
    if (self = [super init]) {
        _loginHandlers = [[NSMutableArray<void (^)(ZPlayer *)> alloc] init];
        _logoutHandlers = [[NSMutableArray<void (^)(ZPlayer *)> alloc] init];

        [handler addLoginHandler:^(ZPlayer *player) {
            //If there is already a player logged in, log them out
            if (self->_player) {
                [self playerLoggedOut];
            }

            self->_player = player;
            [self playerLoggedIn:player];
        }];

        [handler addLogoutHandler:^{
            [self playerLoggedOut];
        }];
    }
    return self;
}

- (void)playerLoggedIn:(ZPlayer *)newPlayer {
    for (id (^handler)(ZPlayer *) in _loginHandlers) {
        handler(newPlayer);
    }
}

- (void)playerLoggedOut {
    if (!_player) {
        return;
    }

    for (id (^handler)(ZPlayer *) in _logoutHandlers) {
        handler(_player);
    }
    _player = nil;
}

- (void)addLoginHandler:(void (^)(ZPlayer *))handler {
    [_loginHandlers addObject:handler];
}

- (void)addLogoutHandler:(void (^)(ZPlayer *))handler {
    [_logoutHandlers addObject:handler];
}

@end
