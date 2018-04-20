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
    //Convert the data to a string
    NSString* json = CreateNSString(data);
    
    //Deserialize the string into a dictionary
    NSDictionary* dict = [ZapicUtils deserialize: json];

    //Sumbit the event
    [Zapic submitEvent:dict];
  }
  
  /// Returns the unique player as json
  const char* z_player(){
    
    ZapicPlayer* player = [Zapic player];
   
    if(player == NULL)
      return NULL;
    
    NSString* json = [ZapicUtils serializeWithData:player];
    
    return MakeStringCopy([json UTF8String]);
  }
  
  /// Handle data provided by Zapic to an external source (push notification, deep link...)
  void z_handleData(char* data){
    //Convert the data to a string
    NSString* json = CreateNSString(data);
    
    //Deserialize the string into a dictionary
    NSDictionary* dict = [ZapicUtils deserialize: json];
    
    [Zapic handleData:dict];
  }
  
  //TODO:DRS Login Handler
  //TODO:DRS Logout handler
}
