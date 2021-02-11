//
//  QPAuthorizePayment.swift
//  QuickPaySDK
//
//  Created on 04/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPAuthorizePaymentRequest: QPRequest {
    
    // MARK: - Properties
    
    var parameters: QPAuthorizePaymentParams
    
    
    // MARK: Init
    
    public init(parameters: QPAuthorizePaymentParams) {
        self.parameters = parameters
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(success: @escaping (_ result: QPPayment) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/payments/\(parameters.id)/authorize"), let postData = try? JSONEncoder().encode(parameters) else {
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

public class QPAuthorizePaymentParams: Codable {
    
    // MARK: - Properties
    
    public var id: Int
    public var amount: Int
    
    public var quickPayCallbackUrl: String? // TODO: Must be encoded/decoded into 'QuickPay-Callback-Url'
    public var synchronized: Bool?
    public var vat_rate: Double?
    public var mobile_number: String?
    public var auto_capture: Bool?
    public var acquirer: String?
    public var autofee: Bool?
    public var customer_ip: String?
//    public var extras: Any?
    public var zero_auth: Bool?
    
    public var card: QPCard?
    public var nin: QPNin?
    public var person: QPPerson?

    
    // MARK: - Init
    
    public init(id: Int, amount: Int) {
        self.id = id
        self.amount = amount
    }
}
