//
//  QPLCreatePaymentParameters.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

class QPCreatePaymentParameters {
    
    // MARK: - Properties
    
    var currency: String?
    var orderId: String?
    var brandingId: Int?
    var textOnStatement: String?
    var variables: Dictionary<String, Any>?

    var basket: Array<QPBasket>?
    var shipping: QPShipping?
    var invoiceAddress: QPAddress?
    var shippingAddress:QPAddress?
    
    var additionalParameters: Dictionary<String, Any>?
    
    
    // MARK: - JSON
    
    public func toDictionary() -> Dictionary<String, Any> {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict["currency"]          = currency
        dict["order_id"]          = orderId
        dict["branding_id"]       = brandingId
        dict["text_on_statement"] = textOnStatement

        dict["basket"]            = QPBasket.arrayToDictionary(baskets: basket)
        dict["variables"]         = variables
        dict["shipping"]          = shipping?.toDictionary()
        dict["invoice_address"]  = invoiceAddress?.toDictionary()
        dict["shipping_address"] = shippingAddress?.toDictionary()
        
        if let additionalParameters = additionalParameters {
            additionalParameters.forEach { (k,v) in dict[k] = v }
        }
        
        return dict
    }
}
