//
//  QPLCreatePaymentParameters.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPCreatePaymentParameters {
    
    // MARK: - Properties
    
    public var currency: String?
    public var orderId: String?
    public var brandingId: Int?
    public var textOnStatement: String?
    public var variables: Dictionary<String, Any> = Dictionary<String, Any>()

    public var basket: Array<QPBasket>? = Array<QPBasket>()
    public var shipping: QPShipping?
    public var invoiceAddress: QPAddress?
    public var shippingAddress:QPAddress?
    
    public var additionalParameters: Dictionary<String, Any>? = Dictionary<String, Any>()
    
    
    // MARK: - Init
    
    public init() {
        
    }
    
    
    // MARK: - Ecodeable
    
    public func toDictionary() -> Dictionary<String, Any> {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict["currency"]          	= currency
        dict["order_id"]          	= orderId
        dict["branding_id"]       	= brandingId
        dict["text_on_statement"] 	= textOnStatement

        dict["basket"]				= QPBasket.arrayToDictionary(baskets: basket)
        dict["public_variables"]    = variables
        dict["shipping"]          	= shipping?.toDictionary()
        dict["invoice_address"]  	= invoiceAddress?.toDictionary()
        dict["shipping_address"] 	= shippingAddress?.toDictionary()
        
        additionalParameters?.forEach { (k,v) in dict[k] = v }

        return dict
    }
}
