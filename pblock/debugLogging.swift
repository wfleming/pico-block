//
//  debugLogging.swift
//  pblock
//
//  Created by Will Fleming on 7/10/15.
//  Copyright © 2015 Will Fleming. All rights reserved.
//

import Foundation

/**
Adapted from https://gist.github.com/Abizern/a81f31a75e1ad98ff80d

Prints the filename, function name, line number and textual representation of `object` and a newline character into
the standard output if the build setting for "Other Swift Flags" defines `-D DEBUG`.

Only the first parameter needs to be passed to this funtion.

The textual representation is obtained from the `message` using its protocol conformances, in the following
order of preference: `Streamable`, `Printable`, `DebugPrintable`. Do not overload this function for your type.
Instead, adopt one of the protocols mentioned above.

:param: message   The object whose textual representation will be printed. If this is an expression, it is lazily evaluated.
:param: file     The name of the file, defaults to the current file without the ".swift" extension.
:param: function The name of the function, defaults to the function within which the call is made.
:param: line     The line number, defaults to the line number within the file that the call is made.
*/
func DLOG<T>(@autoclosure message: () -> T, _ file: String = __FILE__, _ function: String = __FUNCTION__, _ line: Int = __LINE__) {
  #if DEBUG
    let file = file.lastPathComponent.stringByDeletingPathExtension

    print("\(file).\(function)[\(line)]: \(message())\n")
  #endif
}