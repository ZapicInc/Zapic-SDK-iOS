//
//  TokenManagerTests.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/6/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Quick
import Nimble

@testable import Zapic

class TokenManagerSpec: QuickSpec {
    override func spec(){
        
        describe("a token manager"){
            
            var tokenMgr: TokenManager!
            var storage: MemoryStorage!
            
            let bundleId = "com.zapic.demo"
            let validToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIyOmNvbS56YXBpYy5kZW1vIiwic3ViIjoiZGUwZGZmN2ItMzFmMi00NWU3LTg0MTctMTIzNjU4YTNlOTg5IiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.vp38gsf-YqrPHOt2gXb2Ju5iOA5WIM6bbGRB9BitgXM"
            
            describe("with a valid token"){
                
                beforeEach {
                    storage = MemoryStorage()
                    tokenMgr = TokenManager(bundleId: bundleId , storage:storage)
                    
                    tokenMgr.updateToken(validToken)
                }
                
                it("will pass validation"){
                    expect(tokenMgr.hasValidToken()).to(beTrue())
                }
                
                it("will save the token to storage"){
                    expect(storage.count).to(equal(1))
                    expect(storage.values.keys).to(contain(ZapicKey.Token))
                    expect(storage.string(forKey: ZapicKey.Token)).to(match(validToken))
                }
            }
            
            describe("with an invalid token will fail for"){
                
                beforeEach {
                    storage = MemoryStorage()
                    tokenMgr = TokenManager(bundleId: bundleId, storage:storage)
                }
                
                it("invalid issuer"){
                    
                    let invalidIssuer = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpY2x5LmNvbSIsImF1ZCI6IjI6Y29tLnphcGljLmRlbW8iLCJzdWIiOiJkZTBkZmY3Yi0zMWYyLTQ1ZTctODQxNy0xMjM2NThhM2U5ODkiLCJleHAiOjk0NTE3Mjc5OSwiaWF0Ijo5NDM5NjMxOTl9.eynRKSO9_EtWyQRVyLi0Jl20Iv9imtHyznzBUsP3D34"
                    
                    invalidToken(invalidIssuer)
                }
                
                it("blank subject"){
                    
                    let blankSubject = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIwOmNvbS56YXBpYy5kZW1vIiwic3ViIjoiIiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.fj4-vcVvMtlC2R5bL26PDtYmLv4vbQHCo9eZJTqeN0Y"
                    
                    invalidToken(blankSubject)
                }
                
                it("android platform"){
                    
                    let androidToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIxOmNvbS56YXBpYy5kZW1vIiwic3ViIjoiZGUwZGZmN2ItMzFmMi00NWU3LTg0MTctMTIzNjU4YTNlOTg5IiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.UZRWmyUdfcnXR2tOhlONdRIs5-Ri-LsTC5oKNu1GIsY"
                    
                    invalidToken(androidToken)
                }
                
                it("missing bundle id"){
                    
                    let missingBundle = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIwIiwic3ViIjoiIiwiZXhwIjo5NDUxNzI3OTksImlhdCI6OTQzOTYzMTk5fQ.MKeS7BaRSE_JDs4bbPCjfsrkj5Ndj3_hwftlQI5FLzw"
                    
                    invalidToken(missingBundle)
                }
                
                it("wrong bundle id"){
                    
                    let invalidBundle = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2FwaS56YXBpYy5jb20iLCJhdWQiOiIwOmNvbS56YXBpY2x5LmRlbW8iLCJzdWIiOiIiLCJleHAiOjk0NTE3Mjc5OSwiaWF0Ijo5NDM5NjMxOTl9.mGwXdutZsUwPbIlxl1YGkKZAcOlntOVeFQ7sk94q01s"
                    
                    invalidToken(invalidBundle)
                }
                
                func invalidToken(_ token:String){
                    tokenMgr.updateToken(token)
                    expect(tokenMgr.hasValidToken()).to(beFalse())
                }
                
            }
            
            describe("with a saved token"){
                
                it("will automatically load it on startup"){
                    let storage = MemoryStorage()
                    storage.setValue(validToken, forKey: ZapicKey.Token)
                    
                    let tokenMgr = TokenManager(bundleId: bundleId, storage: storage)
                    
                    expect(tokenMgr.hasValidToken()).to(beTrue())
                    expect(tokenMgr.token).to(match(validToken))
                }
            }
        }
    }
}
