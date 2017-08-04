//
//  CInterface.m
//  Zapic
//
//  Created by Daniel Sarfati on 6/30/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

//#import "CInterface.h"
#import <Foundation/Foundation.h>
#import <Zapic/Zapic-Swift.h>

extern "C" {
  
  void z_start(char* version){
    [Zapic startWithVersion:[NSString stringWithUTF8String:version]];
  }
  
  void z_show(char* viewName){
    [Zapic showWithViewName:[NSString stringWithUTF8String:viewName]];
  }
  
  void z_submitEventWithValue(char* eventId, int value){
    [Zapic submitEventWithEventId:[NSString stringWithUTF8String:eventId] value:value error:nil];
  }
  
  void z_submitEvent(char* eventId){
    [Zapic submitEventWithEventId:[NSString stringWithUTF8String:eventId] error:nil];
  }
}
