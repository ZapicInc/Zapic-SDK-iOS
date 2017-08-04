//
//  ZapicTests.swift
//  ZapicTests
//
//  Created by Daniel Sarfati on 7/25/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import XCTest

import Quick
import Nimble

@testable import Zapic

class ZapicSpec: QuickSpec {
  override func spec(){
    
    xdescribe("zapic core"){
      
      var webClient: MockWebClient!
      var zapic:ZapicCore!
      
      beforeEach {
        webClient = MockWebClient()
        zapic = ZapicCore(webClient:webClient)
      }
      
      describe("start"){
        it("should load the web client"){
          zapic.start(version: "1")
          
          expect(webClient.isLoaded).to(beTrue())
        }
        
        it("should only load once"){
          zapic.start(version: "1")
          zapic.start(version: "1")
          
          expect(webClient.loadedCount).to(equal(1))
        }
        
        it("should send the app started event"){
          zapic.start(version: "1")
          
          expect(webClient.eventTotals).to(equal(1))
        }
      }
      
      describe("events"){
        
        it("should fail with reserved event names"){
          expect { try zapic.submitEvent(eventId: ZapicEvents.appStarted.rawValue) }.to(throwError(ZapicError.reservedEventId))
        }
        
        describe("should send events"){
          it("with no value"){
            
            let eventId = "TEST_EVENT"
            
            expect{ try zapic.submitEvent(eventId: eventId) }.toNot(throwError())
            
            expect(webClient.eventCounts[eventId]).to(equal(1))
            expect(webClient.latestValue[eventId]!).to(beNil())
          }
          
          it("with a value"){
  
            let eventId = "TEST_EVENT"
            
            expect{ try zapic.submitEvent(eventId: eventId,value:22) }.toNot(throwError())
            
            expect(webClient.eventCounts[eventId]).to(equal(1))
            expect(webClient.latestValue[eventId]!).to(equal(22))
          }
        }
      }
    }
  }
}

class MockWebClient: ZapicWebClient{
  
  var isLoaded = false
  var loadedCount = 0
  
  var eventTotals = 0
  var eventCounts = [String: Int]()
  var latestValue = [String: Int?]()
  
  func submitEvent(eventId: String, timestamp: Date, value: Int?){
    
    eventTotals += 1
    
    if eventCounts[eventId] == nil {
      eventCounts[eventId] = 1
    }
    else{
      eventCounts[eventId] = eventCounts[eventId]! + 1
    }
    
    latestValue[eventId] = value
    
  }
  func load(){
    isLoaded = true
    loadedCount += 1
  }
  
  var zapicDelegate: ZapicDelegate?  = nil

  func dispatchToJS(type: WebFunction, payload:Any){}
  func dispatchToJS(type: WebFunction, payload:Any, isError: Bool){}
  
  /// Attempt to resend all events that we unable to send
  func resendFailedEvents(){}
}
