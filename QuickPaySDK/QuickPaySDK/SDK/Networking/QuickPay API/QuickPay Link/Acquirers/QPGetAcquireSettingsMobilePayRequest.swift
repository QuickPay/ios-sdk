//
//  QPGetAcquireDetailsMobilePay.swift
//  QuickPaySDK
//
//  Created on 20/03/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPGetAcquireSettingsMobilePayRequest: QPRequest {

    // MARK: - Init
    
    public override init() {
        super.init()
    }

    
    // MARK: - URL Request
    
    public func sendRequest(success: @escaping (_ result: QPMobilePaySettings) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/acquirers/mobilepay") else {
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

public class QPMobilePaySettings: Codable {

    public var active: Bool
    public var delivery_limited_to: String?
    
}
