//
//  QPBasket.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPBasket : Codable {

    // MARK: - Properties
    
    public var qty: Int?
    public var itemNo: String?
    public var itemName: String?
    public var itemPrice: Double?
    public var vatRate: Double?
 
    
    // MARK: - Init
    
    public init() {
        
    }

        
    // MARK: - JSON
    
    public func toDictionary() -> Dictionary<String, Any> {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict[CodingKeys.qty.rawValue] 		= qty
        dict[CodingKeys.itemNo.rawValue] 	= itemNo
        dict[CodingKeys.itemName.rawValue] 	= itemName
        dict[CodingKeys.itemPrice.rawValue] = itemPrice
        dict[CodingKeys.vatRate.rawValue] 	= vatRate
        
        return dict
    }
    
    public func fromDictionary(dict: Dictionary<String, Any>) -> QPBasket {
        let resultBasket = QPBasket()
        
        resultBasket.qty 		= dict[CodingKeys.qty.rawValue] as? Int
        resultBasket.itemNo 	= dict[CodingKeys.itemNo.rawValue] as? String
        resultBasket.itemName	= dict[CodingKeys.itemName.rawValue] as? String
        resultBasket.itemPrice	= dict[CodingKeys.itemPrice.rawValue] as? Double
        resultBasket.vatRate	= dict[CodingKeys.vatRate.rawValue] as? Double
        
        return resultBasket
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
    
    enum CodingKeys: String, CodingKey {
        case qty
        case itemNo		= "item_no"
        case itemName	= "item_name"
        case itemPrice	= "item_price"
        case vatRate	= "vat_rate"
    }
}
