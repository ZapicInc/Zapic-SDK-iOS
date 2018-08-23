#import <Foundation/Foundation.h>
#import "Zapic.h"
#import "ZLog.h"
#import "ZWebViewController.h"

static bool started = false;
static ZWebViewController* _viewController;
static void (^_loginHandler)(ZPlayer*);
static void (^_logoutHandler)(ZPlayer*);

@implementation Zapic : NSObject

+(ZPlayer *) player
{
  return _viewController.playerManager.player;
}

+ (void (^)(ZPlayer*))loginHandler {
  return _loginHandler;
}

+ (void (^)(ZPlayer*))logoutHandler {
  return _logoutHandler;
}

+ (void) setLoginHandler:(void (^)(ZPlayer *))loginHandler {
  _loginHandler = loginHandler;
}

+ (void) setLogoutHandler:(void (^)(ZPlayer *))logoutHandler {
  _logoutHandler = logoutHandler;
}

+ (void)initialize {
  if (self == [Zapic self]) {
    _viewController = [[ZWebViewController alloc]init];
    
    [_viewController.playerManager addLoginHandler:^(ZPlayer* player) {
      if(_loginHandler){
        _loginHandler(player);
      }
    }];
    
    [_viewController.playerManager addLogoutHandler:^(ZPlayer* player) {
      if(_logoutHandler){
        _logoutHandler(player);
      }
    }];
  }
}

+ (void) start{
  
  if(started){
    [ZLog info: @"Zapic is already started. Start should only be called once"];
    return;
  }
  started = true;
  
  [ZLog info:@"Starting Zapic"];
}

+ (void) showPage:(NSString*) pageName{
  [_viewController showPage:pageName];
}

+ (void) showDefaultPage{
  [self showPage:@"default"];
}

+ (void) handleInteraction:(NSDictionary *)data{
  
  if(!data || ![data objectForKey:@"zapic"]){
    [ZLog warn:@"Zapic key not found in handleInteraction data"];
    return;
  }
  
  [_viewController submitEvent:ZEventTypeInteraction withPayload:data];
}

+ (void) handleInteractionString:(NSString*) json{
  
  if(!json){
    [ZLog warn:@"Missing handleInteraction string"];
    return;
  }
  
  NSError* error;
  NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:&error];
  if(!jsonResponse){
    [ZLog warn:@"Interaction string must be valid json"];
    return;
  }
  
  [self handleInteraction:jsonResponse];
}

+ (void) submitEvent:(NSDictionary*) parameters{
  [_viewController submitEvent:ZEventTypeGameplay withPayload:parameters];
}

@end


