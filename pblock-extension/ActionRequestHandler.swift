//
//  ActionRequestHandler.swift
//  pblock-extension
//
//  Created by Will Fleming on 7/9/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

  func beginRequestWithExtensionContext(context: NSExtensionContext) {
    logExtensionRequest()

    let item = NSExtensionItem()

    let fm = NSFileManager.defaultManager()
    let dirURL = fm.containerURLForSecurityApplicationGroupIdentifier("group.com.wfleming.pblock")!
    let filePathURL = dirURL.URLByAppendingPathComponent("blockRules.json")

    if fm.fileExistsAtPath(filePathURL.path!) {
      let attachment = NSItemProvider(contentsOfURL: filePathURL)!
      item.attachments = [attachment]
    }

    context.completeRequestReturningItems([item], completionHandler: nil);
  }

  // DEBUG: log when/how often the extension is refreshed
  func logExtensionRequest() {
    #if DEBUG
      let fm = NSFileManager.defaultManager()
      let dirURL = fm.containerURLForSecurityApplicationGroupIdentifier("group.com.wfleming.pblock")!
      let logURL = dirURL.URLByAppendingPathComponent("events.log")
      let fh = try! NSFileHandle(forWritingToURL: logURL)
      fh.seekToEndOfFile()
      let logLine = "$\(NSDate().description) extension request\n"
      fh.writeData(logLine.dataUsingEncoding(NSUTF8StringEncoding)!)
      fh.closeFile()
    #endif
  }
  
}
