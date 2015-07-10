//
//  AppDelegate.swift
//  pblock
//
//  Created by Will Fleming on 7/9/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    logAppOpen()
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }


  // DEBUG: log app opens to compare with extension requests
  func logAppOpen() {
    #if DEBUG
      let fm = NSFileManager.defaultManager()
      let dirURL = fm.containerURLForSecurityApplicationGroupIdentifier("group.com.wfleming.pblock")!
      let logURL = dirURL.URLByAppendingPathComponent("events.log")
      let fh = try! NSFileHandle(forWritingToURL: logURL)
      fh.seekToEndOfFile()
      let logLine = "$\(NSDate().description) app became active\n"
      fh.writeData(logLine.dataUsingEncoding(NSUTF8StringEncoding)!)
      fh.closeFile()
    #endif
  }
}

