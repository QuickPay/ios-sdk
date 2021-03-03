//
//  QPShopSystem.swift
//  QuickPaySDK
//
//  Created on 29/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPShopSystem : Codable {
    
    // MARK: - Properties
    
    public var name: String
    public var version: String
    
    
    // MARK: Init
    
    public init(name: String, version: String) {
        self.name = name
        self.version = version
    }
}
