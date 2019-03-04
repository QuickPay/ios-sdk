//
//  QPCreateSubscriptionLinkRequest.swift
//  QuickPaySDK
//
//  Created on 30/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPCreateSubscriptionLinkRequest : QPRequest {
    
    // MARK: - Properties
    
    var parameters: QPCreateSubscriptionLinkParameters
    
    
    // MARK: Init
    
    public init(parameters: QPCreateSubscriptionLinkParameters) {
        self.parameters = parameters
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(success: @escaping (_ result: QPSubscriptionLink) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        if parameters.cancel_url == nil {
            parameters.cancel_url = "https://qp.payment.failure"
        }
        else {
            QuickPay.logDelegate?.log("Warning: You have set cancelUrl manually. QPViewController will not be able to detect unsuccessfull input of payment details")
        }
        
        if parameters.continue_url == nil {
            parameters.continue_url = "https://qp.payment.success"
        }
        else {
            QuickPay.logDelegate?.log("Warning: You have set continueUrl manually. QPViewController will not be able to detect successfull input of payment details");
        }
        
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/subscriptions/\(parameters.id)/link"), let putData = try? JSONEncoder().encode(parameters) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = putData
        request.setValue(headers.encodedAuthorization(), forHTTPHeaderField: "Authorization")
        request.setValue(String(format: "%lu", putData.count), forHTTPHeaderField: "Content-Length")
        request.setValue(headers.acceptVersion, forHTTPHeaderField: "Accept-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        super.sendRequest(request: request, success: success, failure: failure)
    }
}
