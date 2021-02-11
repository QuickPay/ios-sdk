//
//  QPShipping.swift
//  QuickPaySDK
//
//  Created on 07/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPShipping : Codable {

    // MARK: - Properties
    
    public var method: String?
    public var company: String?
    public var amount: Int?
    public var vat_rate: Double?
    public var tracking_number: String?
    public var tracking_url: String?
    
    
    // MARK: Init
    
    public init() {
        
    }
    
}
