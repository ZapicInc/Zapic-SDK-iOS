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
      var zapic:ZapicViewController!
      
      beforeEach {
        webClient = MockWebClient()
        zapic = ZapicViewController(webView:webClient)
      }
      
      describe("start"){
        it("should load the web client"){
          zapic.start()
          
          expect(webClient.isLoaded).to(beTrue())
        }
        
        it("should only load once"){
          zapic.start()
          zapic.start()
          
          expect(webClient.loadedCount).to(equal(1))
        }
        
        it("should send the app started event"){
          zapic.start()
          
          expect(webClient.eventTotals).to(equal(1))
        }
      }
      
      describe("events"){
        
//        it("should fail with reserved event names"){
//          expect { try zapic.submitEvent(eventId: ZapicEvents.appStarted.rawValue) }.to(throwError(ZapicError.reservedEventId))
//        }
//        
//        describe("should send events"){
//          xit("with no value"){
//            
////            let eventId = "TEST_EVENT"
////
////            expect{ try zapic.submitEvent(eventId: eventId) }.toNot(throwError())
////
////            expect(webClient.eventCounts[Event.gameplay]).to(equal(1))
////            expect(webClient.latestValue[eventId]!).to(beNil())
//          }
//          
//          it("with a value"){
//  
//            let eventId = "TEST_EVENT"
//            
//            expect{ try zapic.submitEvent(eventType: .gameplay, params: [eventId:22]) }.toNot(throwError())
//            
//            expect(webClient.eventCounts[.gameplay]).to(equal(1))
//            expect(webClient.latestValue[eventId]!).to(equal(22))
//          }
//        }
      }
    }
  }
}

class MockWebClient: ZapicWebView{
  
  var isLoaded = false
  var loadedCount = 0
  
  var eventTotals = 0
  var eventCounts = [EventType: Int]()
  var latestValue = [String: Any]()
  
  func load(){
    isLoaded = true
    loadedCount += 1
  }
  
  func submitEvent(eventType: EventType, params: [String : Any]) {
    eventTotals += 1
    
    if eventCounts[eventType] == nil {
      eventCounts[eventType] = 1
    }
    else{
      eventCounts[eventType] = eventCounts[eventType]! + 1
    }
    
    for kvp in params {
      latestValue[kvp.key] = kvp.value
    }
  }
  
  var zapicDelegate: ZapicDelegate?  = nil

  func dispatchToJS(type: WebFunction, payload:Any){}
  func dispatchToJS(type: WebFunction, payload:Any, isError: Bool){}
  
  /// Attempt to resend all events that we unable to send
  func resendFailedEvents(){}
}
