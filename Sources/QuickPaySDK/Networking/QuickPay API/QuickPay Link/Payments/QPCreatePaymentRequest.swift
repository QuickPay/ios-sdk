//
//  QPCreatePaymentRequest.swift
//  QuickPaySDK
//
//  Created on 07/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPCreatePaymentRequest: QPRequest {
    
    // MARK: - Properties
    
    var parameters: QPCreatePaymentParameters

    
    // MARK: Init
    
    public init(parameters: QPCreatePaymentParameters) {
        self.parameters = parameters
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(success: @escaping (_ result: QPPayment) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/payments"), let postData = try? JSONEncoder().encode(parameters) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(headers.encodedAuthorization(), forHTTPHeaderField: "Authorization")
        request.setValue(String(format: "%lu", postData.count), forHTTPHeaderField: "Content-Length")
        request.setValue(headers.acceptVersion, forHTTPHeaderField: "Accept-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        super.sendRequest(request: request, success: success, failure: failure)
    }
}

public class QPCreatePaymentParameters: Codable {
    
    // MARK: - Properties
    
    public var currency: String
    public var order_id: String
    
    public var branding_id: Int?
    public var text_on_statement: String?
    public var basket: Array<QPBasket>? = Array<QPBasket>()
    public var shipping: QPShipping?
    public var invoice_address: QPAddress?
    public var shipping_address:QPAddress?
    public var shopSystem:QPShopSystem?
    
    
    // MARK: Init
    
    public init(currency: String, order_id: String) {
        self.currency = currency
        self.order_id = order_id
        
        self.shopSystem = QPShopSystem(name: "iOS-SDK", version: "2.0.0")
    }
    
}
