//
//  QuickPaySDKAcquirersTests.swift
//  QuickPaySDK
//
//  Created on 20/03/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import XCTest
import QuickPaySDK

class QuickPaySDKAcquirersTests: QuickPaySDKTestCase {
    
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
}
