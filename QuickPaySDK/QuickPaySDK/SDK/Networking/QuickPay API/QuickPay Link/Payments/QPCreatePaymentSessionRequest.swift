//
//  QPCreatePaymentSessionRequest.swift
//  QuickPaySDK
//
//  Created on 17/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class CreatePaymenSessionRequest: QPRequest {
    
    // MARK: - Properties
    
    var id: Int
    var parameters: CreatePaymenSessionParameters
    
    // MARK: Init
    
    public init(id: Int, parameters: CreatePaymenSessionParameters) {
        self.id = id;
        self.parameters = parameters
        
        // Force the mobilepay session stuff - TODO: REMOVE THIS
        self.parameters.acquirer = "mobilepay"
    }
    
    
    // MARK: - URL Request
    
    public func sendRequest(success: @escaping (_ result: QPPayment) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        guard let url = URL(string: "\(quickPayAPIBaseUrl)/payments/\(self.id)/session?synchronized"), let postData = try? JSONEncoder().encode(parameters) else {
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

public class CreatePaymenSessionParameters: Codable {
    
    // MARK: - Properties
    
    public var amount: Int
    
    public var auto_capture: Bool?
    public var acquirer: String?
    public var autofee: Bool?
    public var customer_ip: String?
    public var person: QPPerson?
    public var extras: QPMobilePayExtras
    
    
    // MARK: Init
    
    public init(amount: Int) {
        self.amount = amount
        self.extras = QPMobilePayExtras()
    }
    
}

public class QPMobilePayExtras: Codable {
    let mobilepay = QPMobilePayParams()
}

public class QPMobilePayParams: Codable {
    let return_url = "quickpaytestshop://"
    let language = "da"
    let shop_logo_url = "https://developer.mobilepay.dk/sites/developer.mobilepay.dk/files/siteImages/logo_icon.png"//https://quickpay.net/gfx/layout/logo-inverse.svg"
}


/*
 extras: {
 mobilepay: {
 return_url: "zliide://app.zliide.com/",
 language: "da",
 shop_logo_url: "http://zliide/logo.png"
 }

 
 
 
 
 res = client.post(
 "/payments/6/session?synchronized",
 body: {
 amount: 100,
 acquirer: "mobilepay",
 }
 }.to_json,
 headers: {
 "Content-Type" => "application/json"
 }
 )
 
 pp o["operations"].last # =>
 {
 "id"=>6,
 "type"=>"session",
 "amount"=>100,
 "pending"=>false,
 "qp_status_code"=>"20000",
 "qp_status_msg"=>"Approved",
 "aq_status_code"=>"0",
 "aq_status_msg"=>"Approved",
 "data"=>{
 "session_token"=>"2019-02-14T16:46:19+00:00.84d0bc0",
 "valid_until"=>"2019-02-14T16:51:19+00:00"
 },
 "callback_url"=>nil,
 "callback_success"=>nil,
 "callback_response_code"=>nil,
 "callback_duration"=>nil,
 "acquirer"=>"mobilepay",
 "3d_secure_status"=>nil,
 "callback_at"=>nil,
 "created_at"=>"2019-02-14T16:46:18Z"
 }

 
 */
