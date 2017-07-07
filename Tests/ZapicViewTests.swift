//
//  ZapicViewTests.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/3/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import XCTest
@testable import Zapic

class ZapicViewTests: XCTestCase {

    var zapicView: ZapicView!

    override func setUp() {
        super.setUp()
        zapicView = ZapicView()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        zapicView = nil
    }

    func testSetTokenBeforeShow() {
        zapicView.setToken(token: "ABC")
        zapicView.show()
    }

    func testTokenAfterShow() {
        zapicView.show()
        zapicView.setToken(token: "ABC")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
