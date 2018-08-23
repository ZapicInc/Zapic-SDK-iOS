//
//  ZSafariManager.h
//  Zapic
//
//  Created by Daniel Sarfati on 8/20/18.
//  Copyright © 2018 Zapic. All rights reserved.
//a

#import <UIKit/UIKit.h>

@interface ZSafariManager : NSObject

/**
 Initialize and configure the manager with the root view controller

 @param viewController The view controller that will hold the Safari view.
 @return The newly created manager.
 */
- (instancetype)initWithController:(UIViewController *)viewController;

/**
 Opens the given url in an embedded safari window
 @param url The url to open.
 */
- (void)openUrl:(NSURL *)url;
@end
