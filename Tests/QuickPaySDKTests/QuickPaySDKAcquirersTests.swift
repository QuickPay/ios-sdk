//
//  QuickPaySDKAcquirersTests.swift
//  QuickPaySDK
//
//  Created on 20/03/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import XCTest
@testable import QuickPaySDK

class QuickPaySDKAcquirersTests: QuickPaySDKTestCase {
    
    static var allTests = [
        ("testMobilePaySettings", testMobilePaySettings),
        ("testClearhausSettings", testClearhausSettings),
        ("testVippsSettings", testVippsSettings)
    ]
    
    func testMobilePaySettings() {
        let mobilePayExpectation = expectation(description: "GET MobilePay")
        var mobilePaySettings: QPMobilePaySettings?

        QPGetAcquireSettingsMobilePayRequest().sendRequest(success: { (settings) in
            mobilePaySettings = settings
            mobilePayExpectation.fulfill()
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(mobilePaySettings)
        }
    }
    
    func testClearhausSettings() {
        let clearhausExpectation = expectation(description: "GET Clearhaus")
        var clearhausSettings: QPClearhausSettings?
        
        QPGetAcquireSettingsClearhausRequest().sendRequest(success: { (settings) in
            clearhausSettings = settings
            clearhausExpectation.fulfill()
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(clearhausSettings)
        }
    }
    
    func testVippsSettings() {
        let vippsExpectation = expectation(description: "GET Vipps")
        var vippsSettings: QPVippsSettings?
        
        QPGetAcquireSettingsVippsRequest().sendRequest(success: { (settings) in
            vippsSettings = settings
            vippsExpectation.fulfill()
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(vippsSettings)
        }
    }
}
