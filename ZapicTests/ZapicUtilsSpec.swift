//
//  ZapicUtilsSpec.swift
//  ZapicTests
//
//  Created by Daniel Sarfati on 10/12/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation
import XCTest

import Quick
import Nimble

@testable import Zapic

class ZapicUtilsSpec: QuickSpec {
  override func spec(){
    describe("zapic utilities"){
      context("serialization"){
        it("supports basic key value pairs"){
          
          // Arrange
          let message = ["a":2]
          let json = ZapicUtils.serialize(data: message);
          let data = (json?.data(using:.utf8))!
          
          // Act
          let result = ZapicUtils.deserialize(bodyData: data)
          
          // Assert
          expect(result).toNot(beNil())
        }
        
        it("allow nested dictionary"){
          
          // Arrange
          let message = ["a":["a1":1]]
          let json = ZapicUtils.serialize(data: message);
          let data = (json?.data(using:.utf8))!
          
          // Act
          let result = ZapicUtils.deserialize(bodyData: data)
          
          // Assert
          expect(result).toNot(beNil())
        }
      }
      context("string formatting"){
        it("handles nil args"){
          
          // Arrange
          let message = "Hello World"
          let args:[String]? = nil
          
          // Act
          let result = ZapicUtils.formatString(message: message, args: args)
          
          // Assert
          expect(result).to(equal(message))
        }
        
        it("handles empty args"){
          
          // Arrange
          let message = "Hello World"
          let args:[String] = []
          
          // Act
          let result = ZapicUtils.formatString(message: message, args: args)
          
          // Assert
          expect(result).to(equal(message))
        }
        
        it("handles an ending arg"){
          
          // Arrange
          let message = "Hello %s"
          let args = ["World"]
          
          // Act
          let result = ZapicUtils.formatString(message: message, args: args)
          
          // Assert
          expect(result).to(equal("Hello World"))
        }
        
        it("handles a starting arg"){
          
          // Arrange
          let message = "%s World"
          let args = ["Hello"]
          
          // Act
          let result = ZapicUtils.formatString(message: message, args: args)
          
          // Assert
          expect(result).to(equal("Hello World"))
        }
        
        it("handles multiple arg"){
          
          // Arrange
          let message = "%s %s"
          let args = ["Hello","World"]
          
          // Act
          let result = ZapicUtils.formatString(message: message, args: args)
          
          // Assert
          expect(result).to(equal("Hello World"))
        }
        
        it("handles neighbor character after an arg"){
          
          // Arrange
          let message = "Hello %s, Again"
          let args = ["World"]
          
          // Act
          let result = ZapicUtils.formatString(message: message, args: args)
          
          // Assert
          expect(result).to(equal("Hello World, Again"))
        }
        
        it("handles neighbor character after an arg"){
          
          // Arrange
          let message = "Hello ,%s Again"
          let args = ["World"]
          
          // Act
          let result = ZapicUtils.formatString(message: message, args: args)
          
          // Assert
          expect(result).to(equal("Hello ,World Again"))
        }
      }
    }
  }
}

