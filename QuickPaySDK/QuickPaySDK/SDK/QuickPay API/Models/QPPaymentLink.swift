//
//  QPPaymentLink.swift
//  QuickPaySDK
//
//  Created on 20/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPPaymentLink : Codable {
    
    // MARK: Properties
    
    public var url: String
    public var agreement_id: Int?
    public var language: String?
    public var amount: Int?
    public var continue_url: String?
    public var cancel_url: String?
    public var callback_url: String?
    public var payment_methods: String?
    public var auto_fee: Bool?
    public var auto_capture: Bool?
    public var branding_id: Int?
    public var google_analytics_client_id: String?
    public var google_analytics_tracking_id: String?
    public var version: String?
    public var acquirer: String?
    public var deadline: String?
    public var framed: Bool?
//    public var branding_config: Any?
    public var invoice_address_selection: Bool?
    public var shipping_address_selection: Bool?
    public var customer_email: String?

}
