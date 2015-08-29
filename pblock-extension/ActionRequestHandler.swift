//
//  ActionRequestHandler.swift
//  pblock-extension
//
//  Created by Will Fleming on 7/9/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

  func beginRequestWithExtensionContext(context: NSExtensionContext) {
    logToGroupLogFile("extension.request")

    let item = NSExtensionItem()

    let fm = NSFileManager.defaultManager()
    let filePathURL = rulesJSONPath()

    if fm.fileExistsAtPath(filePathURL.path!) {
      let attachment = NSItemProvider(contentsOfURL: filePathURL)!
      item.attachments = [attachment]
    }

    context.completeRequestReturningItems([item], completionHandler: nil);
  }
}
