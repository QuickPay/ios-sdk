//
//  QuickPaySDKAbstractTest.swift
//  QuickPaySDK
//
//  Created on 31/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import XCTest
@testable import QuickPaySDK

class QuickPaySDKTestCase: XCTestCase {
    
    // MARK: - Static
    
    internal static let globalTimeout = 5.0

    
    // MARK: Test lifecycle
    
    override func setUp() {
        QuickPay.initWith(apiKey: "f1a4b80189c73862655552d06f9419dd7574c65de916fef88cf9854f6907f1b4")
    }

    
    // MARK: - Utils
    
    func onError(data: Data?, response: URLResponse?, error: Error?) {
        if let response = response {
            print(response)
        }
                
        if let data = data, let str = String(decoding: data, as: UTF8.self) as String? {
            print(str)
        }
        
        if let error = error {
            print(error)
        }
    }
}
