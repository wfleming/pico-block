//
//  FirstViewController.swift
//  pblock
//
//  Created by Will Fleming on 7/9/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func createRules() {
    let filePath = rulesJSONPath().path!
    let content =
    "[" +
    "  {" +
    "    \"action\": {" +
    "      \"type\": \"block\"" +
    "    }," +
    "    \"trigger\": {" +
    "      \"url-filter\": \"webkit.org/images/icon-gold.png\"" +
    "    }" +
    "  }" +
    "]"
    do {
      print("will write rues\n")
      try content.writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
      print("did write rules\n")
    } catch let error as NSError {
      print("an error occurred: $\(error)\n")
    }
  }

  @IBAction func destroyRules() {
    let filePath = rulesJSONPath().path!
    let fm = NSFileManager.defaultManager()
    if fm.fileExistsAtPath(filePath) {
      do {
        print("will delete rules\n")
        try fm.removeItemAtPath(filePath)
        print("did remove rules\n")
      } catch let error as NSError {
        print("an error occurred: $\(error)\n")
      }
    }
  }

  func rulesJSONPath() -> NSURL {
    let fm = NSFileManager.defaultManager()
    let dirURL = fm.containerURLForSecurityApplicationGroupIdentifier("group.com.wfleming.pblock")!
    let filePathURL = dirURL.URLByAppendingPathComponent("blockRules.json")
    return filePathURL
  }
}
