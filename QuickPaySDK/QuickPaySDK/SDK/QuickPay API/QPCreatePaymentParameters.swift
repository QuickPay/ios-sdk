//
//  QPLCreatePaymentParameters.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPCreatePaymentParameters : Codable {
    
    // MARK: - Properties
    
    public var currency: String
    public var order_id: String
    public var branding_id: Int?
    public var text_on_statement: String?
    public var basket: Array<QPBasket>? = Array<QPBasket>()
    public var shipping: QPShipping?
    public var invoice_address: QPAddress?
    public var shipping_address:QPAddress?
    
    
    // MARK: Init
    
    public init(currency: String, order_id: String) {
        self.currency = currency
        self.order_id = order_id
    }
    
}
