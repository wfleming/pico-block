//
//  SplitViewDelegate.swift
//  pblock
//
//  Created by Will Fleming on 8/23/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import UIKit

class SplitViewDelegate: NSObject, NSCoding, UISplitViewControllerDelegate {

  // MARK: NSCoding
  required convenience init(coder decoder: NSCoder) {
    self.init()
  }

  func encodeWithCoder(coder: NSCoder) {
  }

  // MARK: UISplitViewControllerDelegate
  func splitViewController(splitViewController: UISplitViewController,
    collapseSecondaryViewController secondaryViewController:UIViewController,
    ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {
    guard let secondaryAsNavController = secondaryViewController as? UINavigationController else {
      return false
    }
    guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else {
      return false
    }
    if nil == topAsDetailController.detailItem {
      // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
      return true
    }
    return false
  }

}