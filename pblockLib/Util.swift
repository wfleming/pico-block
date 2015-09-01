//
//  Util.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

// convert an ABP glob pattern to a regex string
func globToRegex(glob: String) -> String {
  return glob
    .stringByReplacingOccurrencesOfString(".", withString: "\\.")
    .stringByReplacingOccurrencesOfString("*", withString: ".*")
    // see https://adblockplus.org/en/filters#separators
    .stringByReplacingOccurrencesOfString("^", withString: "[^a-zA-z0-9_\\.\\-%]")
}

// get the path shared by app & extension for the rules JSON
func rulesJSONPath() -> NSURL {
  let fm = NSFileManager.defaultManager()
  let dirURL = fm.containerURLForSecurityApplicationGroupIdentifier("group.com.wfleming.pblock")!
  let filePathURL = dirURL.URLByAppendingPathComponent("blockRules.json")
  return filePathURL
}

func synchronized<T>(obj: AnyObject, blk:() -> T) -> T {
  objc_sync_enter(obj)
  let r = blk()
  objc_sync_exit(obj)
  return r
}

func isTest() -> Bool {
  #if DEBUG
  return nil != PBEnv.get("TEST_ENV")
  #else
  return false
  #endif
}