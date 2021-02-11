//
//  QPCreateSubscriptionParameters.swift
//  QuickPaySDK
//
//  Created on 29/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPCreateSubscriptionParameters: Codable {
    
    // MARK: - Properties
    
    public var order_id: String
    public var currency: String
    public var description: String
    
    public var branding_id: Int?
    public var text_on_statement: String?
    public var basket: Array<QPBasket>?
    public var shipping: QPShipping?
    public var invoice_address: QPAddress?
    public var shipping_address:QPAddress?
    public var group_ids: [Int]?
    public var shopsystem: [QPShopSystem]?
    
    
    // MARK: Init
    
    public init(currency: String, order_id: String, description: String) {
        self.currency = currency
        self.order_id = order_id
        self.description = description
    }
}
