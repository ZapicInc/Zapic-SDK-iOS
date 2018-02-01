//
//  GameScene.m
//  iOS Example ObjC
//
//  Created by Daniel Sarfati on 1/31/18.
//  Copyright © 2018 Zapic. All rights reserved.
//

#import "GameScene.h"
@import Zapic;

@implementation GameScene {
  SKNode *_button;
}

- (void)didMoveToView:(SKView *)view {
  _button =  (SKLabelNode *)[self childNodeWithName:@"//zapicButton"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [touches anyObject];
  CGPoint touchLocation = [touch locationInNode:self];
  
  // Check if the location of the touch is within the button's bounds
  if ([_button containsPoint:touchLocation]) {
    [Zapic showWithViewName:@"main"];
  }
  else{
    [Zapic submitEvent:@{ @"Event123": @34,@"Score":@22}];
    [Zapic submitEventWithJson:@"{\"JSONEvent\":22,\"Value\":1234}"];
  }
}

@end
