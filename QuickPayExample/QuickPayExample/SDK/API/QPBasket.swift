//
//  QPBasket.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

class QPBasket {

    // MARK: - Properties
    
    var qty: Int?
    var itemNo: String?
    var itemName: String?
    var itemPrice: Int?
    var vatRate: Int?
 
    
    // MARK: - JSON
    
    public func toDictionary() -> Dictionary<String, Any> {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict["qty"] = qty
        dict["item_no"] = itemNo
        dict["item_name"] = itemName
        dict["item_price"] = itemPrice
        dict["vat_rate"] = vatRate

        return dict
    }
    
    public class func arrayToDictionary(baskets: Array<QPBasket>?) -> Array<Dictionary<String, Any>> {
        var res = Array<Dictionary<String, Any>>()

        guard let baskets = baskets else {
            return res
        }

        for basket in baskets {
            res.append(basket.toDictionary())
        }
        
        return res;
    }
}
