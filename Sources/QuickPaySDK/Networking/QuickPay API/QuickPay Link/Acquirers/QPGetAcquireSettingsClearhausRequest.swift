//
//  QPGetAcquireSettingsClearhausRequest.swift
//  QuickPaySDK
//
//  Created on 20/03/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPGetAcquireSettingsClearhausRequest: QPRequest {
    
    // MARK: - Init
    
    public override init() {
        super.init()
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(success: @escaping (_ result: QPClearhausSettings) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/acquirers/clearhaus") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(headers.encodedAuthorization(), forHTTPHeaderField: "Authorization")
        request.setValue(headers.acceptVersion, forHTTPHeaderField: "Accept-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        super.sendRequest(request: request, success: success) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                if httpUrlResponse.statusCode == QuickPayHttpStatusCodes.unauthorized.rawValue {
                    QuickPay.logDelegate?.log("The API key needs permissions for 'GET  /acquirers/clearhaus'")
                }
            }
            
            failure?(data, response, error)
        }
    }
    
}

public class QPClearhausSettings: Codable {
    
    public var active: Bool
    public var api_key: String
    public var apple_pay: Bool
    public var recurring: Bool
    public var payout: Bool
    public var mpi_merchant_id: String?
    
}
