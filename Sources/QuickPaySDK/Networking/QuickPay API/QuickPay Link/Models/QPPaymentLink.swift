//
//  QPPaymentLink.swift
//  QuickPaySDK
//
//  Created on 20/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPPaymentLink: Codable {
    
    // MARK: Properties
    
    public var url: String
    
    
    // MARK: Init
    
    public init(url: String) {
        self.url = url
    }
}

