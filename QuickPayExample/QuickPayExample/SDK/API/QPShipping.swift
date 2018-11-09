//
//  QPShipping.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

class QPShipping {

    // MARK: - Properties
    
    var method: String?
    var company: String?
    var amount: Int?
    var vatRate: Float?
    var trackingNumber: String?
    var trackingUrl: String?
    
    
    // MARK: - JSON
    
    public func toDictionary() -> Dictionary<String, Any> {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict["method"]          = method
        dict["company"]         = company
        dict["amount"]          = amount
        dict["vat_rate"]        = vatRate
        dict["tracking_number"] = trackingNumber
        dict["tracking_url"]    = trackingUrl
        
        return dict
    }
}
