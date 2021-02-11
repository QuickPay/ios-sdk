//
//  QPCreateSubscriptionLinkParameters.swift
//  QuickPaySDK
//
//  Created on 30/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPCreateSubscriptionLinkParameters : Codable {
    
    // MARK: - Properties
    
    public var id: Int
    public var amount: Double
    public var agreement_id: Int?
    public var language: String?
    public var continue_url: String?
    public var cancel_url: String?
    public var callback_url: String?
    public var payment_methods: String?
    public var auto_fee: Bool?
    public var branding_id: Int?
    public var google_analytics_tracking_id: String?
    public var google_analytics_client_id: String?
    public var acquirer: String?
    public var deadline: String?
    public var framed: Int?
//    public var branding_config: Any?
    public var customer_email: String?
    public var invoice_address_selection: Bool?
    public var shipping_address_selection: Bool?
    
    
    // MARK: Init
    
    public init(id: Int, amount: Double) {
        self.id = id
        self.amount = amount
    }
}
