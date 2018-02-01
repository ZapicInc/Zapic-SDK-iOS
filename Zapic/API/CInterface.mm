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

// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
  if (string)
    return [NSString stringWithUTF8String: string];
  else
    return [NSString stringWithUTF8String: ""];
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
  if (string == NULL)
    return NULL;
  
  char* res = (char*)malloc(strlen(string) + 1);
  strcpy(res, string);
  return res;
}

extern "C" {
  
  void z_start(){
    [Zapic start];
  }
  
  void z_show(char* viewName){
    [Zapic showWithViewName:CreateNSString(viewName)];
  }
  
  void z_submitEventWithParams(char* data){
    [Zapic submitEventWithJson:CreateNSString(data)];
  }
  
  /// Returns the unique player id
  const char* z_playerId(){
    
    NSString* uid = [Zapic playerId];
    
    if(uid == NULL)
      return NULL;
    
    return MakeStringCopy([uid UTF8String]);
  }
}
