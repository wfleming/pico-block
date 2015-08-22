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
    logToGroupLogFile("extension.request \(NSDate().description)")

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
}
