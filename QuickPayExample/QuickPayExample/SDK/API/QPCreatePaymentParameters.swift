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

    var variables: Dictionary<String, String>?
    var basket: Array<QPBasket>?
    var shipping: QPShipping?
    var invoiceAddress: QPAddress?
    var shippingAddress:QPAddress?
}
