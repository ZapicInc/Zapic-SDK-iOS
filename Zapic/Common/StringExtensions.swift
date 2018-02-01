//
//  StringExtensions.swift
//  Zapic
//
//  Created by Daniel Sarfati on 10/27/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

extension String {

  func asUUID() -> UUID? {
    return UUID(uuidString: self)
  }

  func indicesOf(string: String) -> [Int] {
    var indices = [Int]()
    var searchStartIndex = self.startIndex

    while searchStartIndex < self.endIndex,
      let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
      !range.isEmpty {
        let index = distance(from: self.startIndex, to: range.lowerBound)
        indices.append(index)
        searchStartIndex = range.upperBound
    }

    return indices
  }

  func replaceSubstrings(string: String, args: [String]) -> String {

    var outString = ""
    var argIndex = 0
    var prevChar: Character = " "
    var index = 0
    var skip = true

    for char in self {

      if char == "s" && prevChar == "%"{
        let arg = args[argIndex]
        argIndex += 1

        outString.append(arg)

        skip = true

      } else if index == self.count-1 {
        outString.append(prevChar)
        outString.append(char)
        return outString
      } else {
        if !skip {
          outString.append(prevChar)
        }
        skip = false
        prevChar = char
      }

      index += 1
    }

    return outString
  }
}
