//
//  AppDelegate.swift
//  iOS Example
//
//  Created by Daniel Sarfati on 7/12/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import UIKit
import Zapic
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    //Update OneSignal when the player is logs into Zapic
    Zapic.onLoginHandler = {(player: ZapicPlayer) -> Void in
      OneSignal.sendTag(Zapic.notificationTag, value:player.notificationToken);
    }
    
    //Remove the previousPlayer from OneSignal when the player is logs out of Zapic
    Zapic.onLogoutHandler = {(prevPlayer: ZapicPlayer) -> Void in
      OneSignal.deleteTag(Zapic.notificationTag);
    }
    

    let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
    
    // Replace 'YOUR_APP_ID' with your OneSignal App ID.
    OneSignal.initWithLaunchOptions(launchOptions,
                                    appId: "cd7f9dc7-0fe6-435b-84ec-6534c2a6b361",
                                    handleNotificationAction: { (result) in
                                      
                                      let data = result?.notification.payload.additionalData
                                      
                                      Zapic.handleInteraction(data)
                                    },
                                    settings: onesignalInitSettings)
    
    OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
    
    OneSignal.promptForPushNotifications(userResponse: { accepted in
      print("User accepted notifications: \(accepted)")
    })
    
    ZLog.isEnabled = true
    Zapic.start()   
    
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

