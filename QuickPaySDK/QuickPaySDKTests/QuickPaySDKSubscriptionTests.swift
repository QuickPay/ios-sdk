//
//  QuickPaySDKSubscriptionTests.swift
//  QuickPaySDK
//
//  Created on 31/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import XCTest
import QuickPaySDK

class QuickPaySDKSubscriptionTests: QuickPaySDKTestCase {

    func testPOSTSubscription() {
        let subscriptionExpectation = expectation(description: "POST /subscriptions")
        var subscriptionResponse: QPSubscription?
        
        SDKUtils.createSubscriptionRequest().sendRequest(success: { (subscription) in
            subscriptionResponse = subscription
            subscriptionExpectation.fulfill()
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(subscriptionResponse)
        }
    }
    
    func testPUTSubscriptionLink() {
        let subscriptionLinkExpectation = expectation(description: "PUT /subscriptions/{id}/link")
        var subscriptionLinkResponse: QPSubscriptionLink?
        
        SDKUtils.createSubscriptionRequest().sendRequest(success: { (subscription) in
            SDKUtils.createSubscriptionLinkRequest(id: subscription.id).sendRequest(success: { (subscriptionLink) in
                subscriptionLinkResponse = subscriptionLink
                subscriptionLinkExpectation.fulfill()
            }, failure: super.onError)
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(subscriptionLinkResponse)
        }
    }
    
    func testGetSubscription() {
        let subscriptionExpectation = expectation(description: "GET /subscriptions/{id}")
        var subscriptionResponse: QPSubscription?
        
        SDKUtils.createSubscriptionRequest().sendRequest(success: { (subscription) in
            QPGetSubscriptionRequest(id: subscription.id).sendRequest(success: { (subscription) in
                subscriptionResponse = subscription
                subscriptionExpectation.fulfill()
            }, failure: super.onError)
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(subscriptionResponse)
        }
    }
    
}
