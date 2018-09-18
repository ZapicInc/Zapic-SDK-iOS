//
//  AppDelegate.m
//  ZapicExample-ObjC
//
//  Created by Daniel Sarfati on 7/12/18.
//  Copyright © 2018 Zapic. All rights reserved.
//

#import "AppDelegate.h"
@import Zapic;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  Zapic.loginHandler = ^(ZPCPlayer* p) {
    NSLog(@"Player logged in");
    //Do stuff here
    
    [Zapic getChallenges:^(NSArray<ZPCChallenge *> *challenges, NSError *error) {
      if(error){
        NSLog(@"Error getting challenges");
      }else{
        NSLog(@"Found %lu challenges!",(unsigned long)challenges.count);
      }
    }];
    
    [Zapic getStatistics:^(NSArray<ZPCStatistic *> *statistics, NSError *error) {
      if(error){
        NSLog(@"Error getting stats");
      }else{
        NSLog(@"Found %lu stats!",(unsigned long)statistics.count);
      }
    }];
    
    [Zapic getCompetitions:^(NSArray<ZPCCompetition *> *competitions, NSError *error) {
      if(error){
        NSLog(@"Error getting competitions");
      }else{
        NSLog(@"Found %lu competitions!",(unsigned long)competitions.count);
      }
    }];
    
    [Zapic getPlayer:^(ZPCPlayer *player, NSError *error) {
      if(error){
        NSLog(@"Error getting player");
      }else{
        NSLog(@"Got the player");
      }
    }];
    
  };
  
  Zapic.logoutHandler = ^(ZPCPlayer* p) {
    NSLog(@"Player logged out");
    //Do stuff here
  };
  
  [Zapic start];
  
  /*
   Get the current player, this will very likely be nil since
   Zapic is still loading the player at this point.
   */
  [Zapic getPlayer:^(ZPCPlayer *player, NSError *error) {
    NSLog(@"Current player: %@", player);
  }];
  
  // Override point for customization after application launch.
  return YES;
}
@end
