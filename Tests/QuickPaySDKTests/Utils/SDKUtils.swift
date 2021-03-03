//
//  SDKUtils.swift
//  QuickPaySDK
//
//  Created on 29/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation
@testable import QuickPaySDK

class SDKUtils {
    
    class func generateRandomOrderId() -> String {
        let randomString = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(randomString.prefix(20))
    }
    
    
    // MARK: - Payments
    
    class func createPaymentRequest() -> QPCreatePaymentRequest {
        // Create the params needed for creating a payment
        let params = QPCreatePaymentParameters(currency: "DKK", order_id: SDKUtils.generateRandomOrderId())
        
        // Fill the basket with the customers cosen items
        params.basket?.append(QPBasket(qty: 3, item_no: "123", item_name: "Test Item", item_price: 56.0, vat_rate: 0.25))
        
        return QPCreatePaymentRequest(parameters: params)
    }
    
    class func createPaymentLinkRequest(id: Int) -> QPCreatePaymentLinkRequest {
        return QPCreatePaymentLinkRequest(parameters: QPCreatePaymentLinkParameters(id: id, amount: 12300))
    }
    
    class func getPayment(id: Int) -> QPGetPaymentRequest {
        return QPGetPaymentRequest(id: id)
    }

    
    // MARK: - Subscriptions

    class func createSubscriptionRequest() -> QPCreateSubscriptionRequest {
        // Create the params needed for creating a subscription
        let params = QPCreateSubscriptionParameters(currency: "DKK", order_id: SDKUtils.generateRandomOrderId(), description: "QuickPay Example Shop Subscription")
        
        // Fill the basket with the customers cosen items
        params.basket?.append(QPBasket(qty: 3, item_no: "123", item_name: "Test Item", item_price: 56.0, vat_rate: 0.25))
        
        return QPCreateSubscriptionRequest(parameters: params)
    }
    
    class func createSubscriptionLinkRequest(id: Int) -> QPCreateSubscriptionLinkRequest {
        return QPCreateSubscriptionLinkRequest(parameters: QPCreateSubscriptionLinkParameters(id: id, amount: 12300))
    }

}
