//
//  Util.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation

func globToRegex(glob: String) -> String {
  return glob
    .stringByReplacingOccurrencesOfString(".", withString: "\\.")
    .stringByReplacingOccurrencesOfString("*", withString: ".*")
    // see https://adblockplus.org/en/filters#separators
    .stringByReplacingOccurrencesOfString("^", withString: "[^a-zA-z0-9_\\.\\-%]")
}