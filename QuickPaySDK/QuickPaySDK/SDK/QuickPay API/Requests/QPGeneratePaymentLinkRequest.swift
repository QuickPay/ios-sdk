//
//  QPGeneratePaymentLinkRequest.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 12/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPGeneratePaymentLinkRequest : QPRequest {

    // MARK: - Properties
    
    var parameters: QPGeneratePaymentLinkParameters

    
    // MARK: Init
    
    public init(parameters: QPGeneratePaymentLinkParameters) {
        self.parameters = parameters
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(completion: @escaping (_ paymentLink: QPPaymentLink?, _ data: Data?) -> Void) {
        if parameters.cancel_url == nil {
            parameters.cancel_url = "https://qp.payment.failure"
        }
        else {
            print("Warning: You have set cancelUrl manually. QPViewController will not be able to detect unsuccessfull input of payment details")
        }

        if parameters.continue_url == nil {
            parameters.continue_url = "https://qp.payment.success"
        }
        else {
            print("Warning: You have set continueUrl manually. QPViewController will not be able to detect successfull input of payment details");
        }
        
        let encoder = JSONEncoder()
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/payments/\(parameters.id)/link"), let putData = try? encoder.encode(parameters) else {
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
        
        super.sendRequest(request: request) { (data) in
            guard let data = data else {
                completion(nil, nil)
                return
            }

            if let result = try? JSONDecoder().decode(QPPaymentLink.self, from: data) {
                completion(result, data)
            }
            else {
                completion(nil, data)
            }
        }
    }
}
