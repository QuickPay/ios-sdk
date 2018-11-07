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
}


//-(NSDictionary *) toDictionary;
//-(void) fromDictionary:(NSDictionary *)dict;
//+(NSDictionary*) shippingToDictionary:(QPLShipping *)shipping;
//+(QPLShipping*) shippingFromDictionary:(NSDictionary*) dict;
