//
//  TokenManagerTests.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/6/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import XCTest
@testable import Zapic

class TokenManagerTests: XCTestCase {

    var tokenMgr:TokenManager!;
    
    override func setUp() {
        super.setUp()

        tokenMgr = TokenManager(bundleId: "com.zapic.demo")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        tokenMgr = nil
    }
    
    func testValidToken() {
        
        let validToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIwOmNvbS56YXBpYy5kZW1vIiwic3ViIjoiZGUwZGZmN2ItMzFmMi00NWU3LTg0MTctMTIzNjU4YTNlOTg5IiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.fr5ppJUIttCegqqBl7TTnJCscV74fxV4rf9Fh4UGbLA"
        
        tokenMgr.updateToken(newToken: validToken)
        
        XCTAssertTrue(tokenMgr.hasValidToken())
    }
    
    func testInvalidIssuer() {
        
         let invalidIssuer = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpY2x5LmNvbSIsImF1ZCI6IjA6Y29tLnphcGljLmRlbW8iLCJzdWIiOiJkZTBkZmY3Yi0zMWYyLTQ1ZTctODQxNy0xMjM2NThhM2U5ODkiLCJleHAiOjk0NTE3Mjc5OSwiaWF0Ijo5NDM5NjMxOTl9.n2HlsNCA1HBPMtnk6RE3QyD36vD_ZJvpRALdG9_ItUg"
        
        tokenMgr.updateToken(newToken: invalidIssuer)
        
        XCTAssertFalse(tokenMgr.hasValidToken())
    }
    
    func testBlankSubject() {
        
        let blankSubject = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIwOmNvbS56YXBpYy5kZW1vIiwic3ViIjoiIiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.fj4-vcVvMtlC2R5bL26PDtYmLv4vbQHCo9eZJTqeN0Y"

        
        tokenMgr.updateToken(newToken: blankSubject)
        
        XCTAssertFalse(tokenMgr.hasValidToken())
    }
    
    func testAndroid() {
        
        let androidToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIxOmNvbS56YXBpYy5kZW1vIiwic3ViIjoiZGUwZGZmN2ItMzFmMi00NWU3LTg0MTctMTIzNjU4YTNlOTg5IiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.UZRWmyUdfcnXR2tOhlONdRIs5-Ri-LsTC5oKNu1GIsY"

        tokenMgr.updateToken(newToken: androidToken)
        
        XCTAssertFalse(tokenMgr.hasValidToken())
    }
    
    func testWrongBundleId() {
        
        let invalidBundle = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIwOmNvbS56YXBpY2x5LmRlbW8iLCJzdWIiOiIiLCJleHAiOjk0NTE3Mjc5OSwiaWF0Ijo5NDM5NjMxOTl9.mGwXdutZsUwPbIlxl1YGkKZAcOlntOVeFQ7sk94q01s"

        tokenMgr.updateToken(newToken: invalidBundle)
        
        XCTAssertFalse(tokenMgr.hasValidToken())
    }
    
    func testMissingBundleId() {
        
        let missingBundle = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIwIiwic3ViIjoiIiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.MKeS7BaRSE_JDs4bbPCjfsrkj5Ndj3_hwftlQI5FLzw"
        

        tokenMgr.updateToken(newToken: missingBundle)
        
        XCTAssertFalse(tokenMgr.hasValidToken())
    }
}
