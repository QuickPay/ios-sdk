//
//  QPGetSubscriptionRequest.swift
//  QuickPaySDK
//
//  Created on 02/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPGetSubscriptionRequest : QPRequest {
    
    // MARK: - Properties
    
    public var id: Int
    
    
    // MARK: - Init
    
    public init(id: Int) {
        self.id = id
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(success: @escaping (_ result: QPSubscription) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/subscriptions/\(self.id)") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(headers.encodedAuthorization(), forHTTPHeaderField: "Authorization")
        request.setValue(headers.acceptVersion, forHTTPHeaderField: "Accept-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        super.sendRequest(request: request, success: success, failure: failure)
    }
}
