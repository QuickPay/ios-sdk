//
//  QPPayment.swift
//  QuickPaySDK
//
//  Created on 07/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPPayment: Codable {
    
    // MARK: - Properties
    
    public var id: Int
    public var merchant_id: Int
    public var order_id: String
    public var accepted: Bool
    public var type: String
    public var text_on_statement: String?
    public var currency: String
    public var state: String
    public var test_mode: Bool
    public var created_at: String
    public var updated_at: String
    public var balance: Int
    
    public var branding_id: String?
    public var acquirer: String?
    public var facilitator: String?
    public var retented_at: String?
    public var fee: Int?
    public var subscriptionId: Int?
    public var deadline_at: String?

    public var operations: Array<QPOperation>?
    public var shipping_address: QPAddress?
    public var invoice_address: QPAddress?
    public var basket: Array<QPBasket>?
    public var shipping: QPShipping?
    public var metadata: QPMetadata?
    public var link: QPPaymentLink?
    public var shopsystem: QPShopSystem?
    
}
