//
//  DefaultData.swift
//  pblock
//
//  Created by Will Fleming on 8/22/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation
import UIKit

class DefaultData  {
  struct DefaultRuleSourceDescriptor {
    var name: String,
        url: String,
        parserType: String? //RuleFileParserProtocol.Type? (TODO: make this work)
  }

  static let uBlockUrl = "https://raw.githubusercontent.com/chrisaljoudi/uBlock/master/assets/ublock"

  static let defaultRuleSources = [
    DefaultRuleSourceDescriptor(
      name: "uBlock filters",
      url: "\(uBlockUrl)/filters.txt",
      parserType: "ABPRuleFileParser" //ABPRuleFileParser.self
    ),
    DefaultRuleSourceDescriptor(
      name: "uBlock privacy filters",
      url: "\(uBlockUrl)/privacy.txt",
      parserType: "ABPRuleFileParser" //ABPRuleFileParser.self
    ),
    DefaultRuleSourceDescriptor(
      name: "AdBlockPlus EasyList",
      url: "https://easylist-downloads.adblockplus.org/easylist.txt",
      parserType: "ABPRuleFileParser" //ABPRuleFileParser.self
    ),
    DefaultRuleSourceDescriptor(
      name: "AdBlockPlus EasyPrivacy",
      url: "https://easylist-downloads.adblockplus.org/easyprivacy.txt",
      parserType: "ABPRuleFileParser" //ABPRuleFileParser.self
    ),
// these aren't currently available over HTTPS: could set up https mirrors?
//    DefaultRuleSourceDescriptor(
//      name: "Peter Lowe’s Ad server list‎",
//      url: "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=1&mimetype=plaintext",
//      parserType: "HostFileParser" //HostFileParser.self
//    ),
//    DefaultRuleSourceDescriptor(
//      name: "Malware Domain List‎",
//      url: "http://www.malwaredomainlist.com/hostslist/hosts.txt",
//      parserType: "HostFileParser" //HostFileParser.self
//    ),
//    DefaultRuleSourceDescriptor(
//      name: "Malware Domains‎",
//      url: "http://mirror1.malwaredomains.com/files/justdomains",
//      parserType: "HostFileParser" //HostFileParser.self
//    ),
    DefaultRuleSourceDescriptor(
      name: "My Filters",
      url: "localhost",
      parserType: nil
    )
  ]

  class func setup() {
    let coreDataMgr = CoreDataManager.sharedInstance

    defaultRuleSources.forEach { (DefaultRuleSourceDescriptor rsd) -> () in
      let ruleSource = RuleSource(inContext: coreDataMgr.managedObjectContext!)
      ruleSource.name = rsd.name
      ruleSource.url = rsd.url
      if let parserClass = rsd.parserType {
//        let pieces = _stdlib_getDemangledTypeName(parserClass).componentsSeparatedByString(".")
//        ruleSource.parserType = pieces[pieces.count - 2]
        ruleSource.parserType = parserClass
      }
    }

    do {
      try coreDataMgr.managedObjectContext?.save()
    } catch let error {
      dlog("save failed: \(error)")
    }
  }
}