//
//  QuickPaySDKTests.swift
//  QuickPaySDK
//
//  Created on 29/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import XCTest
@testable import QuickPaySDK

class QuickPaySDKPaymentTests: QuickPaySDKTestCase {    
    
    static var allTests = [
        ("testPOSTPayment", testPOSTPayment),
        ("testPUTPaymentLink", testPUTPaymentLink),
        ("testGETPayment", testGETPayment)
    ]
    
    func testPOSTPayment() {
        let paymentExpectation = expectation(description: "POST /payments")
        var paymentResponse: QPPayment?
        
        SDKUtils.createPaymentRequest().sendRequest(success: { (payment) in
            paymentResponse = payment
            paymentExpectation.fulfill()
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(paymentResponse)
        }
    }
    
    func testPUTPaymentLink() {
        let paymentLinkExpectation = expectation(description: "PUT /payments/{id}/link")
        var paymentLinkResponse: QPPaymentLink?
        
        SDKUtils.createPaymentRequest().sendRequest(success: { (payment) in
            SDKUtils.createPaymentLinkRequest(id: payment.id).sendRequest(success: { (paymentLink) in
                paymentLinkResponse = paymentLink
                paymentLinkExpectation.fulfill()
            }, failure: super.onError)
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(paymentLinkResponse)
        }
    }
    
    func testGETPayment() {
        let paymentExpectation = expectation(description: "GET /payment/{id}")
        var paymentResponse: QPPayment?
        
        SDKUtils.createPaymentRequest().sendRequest(success: { (payment) in
            QPGetPaymentRequest(id: payment.id).sendRequest(success: { (payment) in
                paymentResponse = payment
                paymentExpectation.fulfill()
            }, failure: super.onError)
        }, failure: super.onError)
        
        waitForExpectations(timeout: QuickPaySDKTestCase.globalTimeout) { (error) in
            XCTAssertNotNil(paymentResponse)
        }
    }
}
