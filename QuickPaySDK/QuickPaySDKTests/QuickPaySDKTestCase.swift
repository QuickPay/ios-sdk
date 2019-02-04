//
//  QuickPaySDKAbstractTest.swift
//  QuickPaySDK
//
//  Created on 31/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import XCTest
import QuickPaySDK

class QuickPaySDKTestCase: XCTestCase {
    
    // MARK: - Static
    
    internal static let globalTimeout = 5.0

    
    // MARK: Test lifecycle
    
    override func setUp() {
        QuickPay.initWith(authorization: "e42538f4ca60b415f13d147aa3158d09c25c8f4f4111c5c0b8356518c2fb03a7")
    }
    
}
