//
//  GroupLog.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 PBlock. All rights reserved.
//

import Foundation

/**
Adapted from https://gist.github.com/Abizern/a81f31a75e1ad98ff80d

Prints the filename, function name, line number and textual representation of `object` and a newline character into
the standard output if the build setting for "Other Swift Flags" defines `-D DEBUG`.

Only the first parameter needs to be passed to this function.

The textual representation is obtained from the `message` using its protocol conformances, in the following
order of preference: `Streamable`, `Printable`, `DebugPrintable`. Do not overload this function for your type.
Instead, adopt one of the protocols mentioned above.

:param: message   The object whose textual representation will be printed. If this is an expression, it is lazily evaluated.
:param: file     The name of the file, defaults to the current file without the ".swift" extension.
:param: function The name of the function, defaults to the function within which the call is made.
:param: line     The line number, defaults to the line number within the file that the call is made.
*/
func dlog<T>(@autoclosure message: () -> T, _ file: NSString = __FILE__, _ function: String = __FUNCTION__, _ line: Int = __LINE__) {
  #if DEBUG
    let file = (file.lastPathComponent as NSString).stringByDeletingPathExtension

    print("\(file).\(function)[\(line)]: \(message())\n")
  #endif
}

/**
Log a message to a file shared by the app group.
*/
func logToGroupLogFile(message: String) {
  #if DEBUG
    let fm = NSFileManager.defaultManager()
    let dirURL = fm.containerURLForSecurityApplicationGroupIdentifier("group.com.wfleming.pblock")
    if nil == dirURL {
      print("Could not get group directory: cannot log message \"\(message)\"\n")
    } else {
      let logURL = dirURL!.URLByAppendingPathComponent("events.log")
      if !fm.fileExistsAtPath(logURL.path!) {
        "".dataUsingEncoding(NSUTF8StringEncoding)?.writeToURL(logURL, atomically: true)
        if !fm.fileExistsAtPath(logURL.path!) {
          print("Failed to create logfile in group directory\n")
          return
        }
      }
      do {
        let fh = try NSFileHandle(forWritingToURL: logURL)
        defer {
          fh.closeFile()
        }
        fh.seekToEndOfFile()
        let logLine = "\(NSDate().description) $\(message)\n"
        fh.writeData(logLine.dataUsingEncoding(NSUTF8StringEncoding)!)
      } catch {
        print("Error encountered trying to write message \"\(message)\"to group log: \(error)\n")
      }
    }
  #endif
}