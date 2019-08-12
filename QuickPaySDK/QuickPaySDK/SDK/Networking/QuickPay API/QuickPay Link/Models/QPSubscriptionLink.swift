//
//  QPSubscriptionLink.swift
//  QuickPaySDK
//
//  Created on 30/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPSubscriptionLink : Codable {
    
    // MARK: Properties
    
    public var url: String
    

    // MARK: Init
    
    public init(url: String) {
        self.url = url
    }
}
