//
//  AppEnv.swift
//  pblock
//
//  Created by Will Fleming on 9/26/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import UIKit

class AppEnv {
  static let sharedInstance = AppEnv()

  private var plistDict: NSDictionary

  // BEGIN env keys
  lazy var appGroup: String = { self.readValue("appGroup") as! String }()
  // END env keys

  internal required init() {
    let path = NSBundle.mainBundle().pathForResource("AppEnv", ofType: "plist")
    if nil == path {
      dlog("No AppEnv.plist found.")
      exit(1)
    }

    plistDict = NSDictionary(contentsOfFile: path!)!
  }

  private func readValue(key: String) -> AnyObject? {
    return plistDict[key]
  }
}
