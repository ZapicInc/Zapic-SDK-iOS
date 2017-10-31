//
//  StringExtensionsSpec.swift
//  ZapicTests
//
//  Created by Daniel Sarfati on 10/27/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation
import XCTest

import Quick
import Nimble

@testable import Zapic

class StringExtensionsSpec: QuickSpec {
  override func spec(){
    describe("strings"){
      context("convert to a UUID"){
        it("is valid format with dashes"){
          
          // Arrange
          let idString = "9bd76e20-f408-4a8f-af94-c65da4378e66"
          
          // Act
          let result = idString.asUUID()
          
          // Assert
          expect(result).toNot(beNil())
          expect(result?.uuidString.lowercased()).to(equal(idString.lowercased()))
        }
        
        it("is invalid without dashes"){
          
          // Arrange
          let idString = "9bd76e20f4084a8faf94c65da4378e66"
          
          // Act
          let result = idString.asUUID()
          
          // Assert
          expect(result).to(beNil())
        }
      }
    }
  }
}
