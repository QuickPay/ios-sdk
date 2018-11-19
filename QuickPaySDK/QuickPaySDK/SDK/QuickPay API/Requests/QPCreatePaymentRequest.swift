//
//  File.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPCreatePaymentRequest : QPRequest {
    
    // MARK: - Properties
    
    var parameters: QPCreatePaymentParameters

    
    // MARK: Init
    
    public init(headers: QPHeaders, parameters: QPCreatePaymentParameters) {
        self.parameters = parameters
        super.init(headers: headers)
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(completion: @escaping (_ response: QPCreatePaymentResponse?, _ data: Data?) -> Void) {
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/payments"), let postData = try? JSONSerialization.data(withJSONObject: self.parameters.toDictionary(), options: []) else {
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
        
        super.sendRequest(request: request) { (data) in
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            if let result = try? JSONDecoder().decode(QPCreatePaymentResponse.self, from: data) {
                completion(result, data)
            }
            else {
                completion(nil, data)
            }
        }
    }
}

public struct QPCreatePaymentResponse : Codable {
    public let id: Int
}
