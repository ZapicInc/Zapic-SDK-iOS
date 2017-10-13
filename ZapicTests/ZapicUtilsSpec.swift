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
    }
  }
}

