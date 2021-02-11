//
//  QPCreatePaymentSessionRequest.swift
//  QuickPaySDK
//
//  Created on 17/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPCreatePaymentSessionRequest: QPRequest {
    
    // MARK: - Properties
    
    var id: Int
    var parameters: QPCreatePaymentSessionParameters

    
    // MARK: Init
    
    public init(id: Int, parameters: QPCreatePaymentSessionParameters) {
        self.id = id;
        self.parameters = parameters
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
        
        super.sendRequest(request: request, success: success) { (data, response, error) in
            if let httpUrlResponse = response as? HTTPURLResponse {
                if httpUrlResponse.statusCode == QuickPayHttpStatusCodes.unauthorized.rawValue {
                    QuickPay.logDelegate?.log("The API key needs permissions for 'POST /payments/:id/session'")
                }
            }
            
            failure?(data, response, error)
        }
    }
}

public class QPCreatePaymentSessionParameters: Encodable {
    
    // MARK: - Properties
    
    public var amount: Int
    
    public var auto_capture: Bool?
    public var acquirer: String?
    public var autofee: Bool?
    public var customer_ip: String?
    public var person: QPPerson?
    public var extras: Dictionary<String,EncodableValue>?

    
    // MARK: Init
    
    public init(amount: Int) {
        self.amount = amount
    }
    
    public convenience init(amount: Int, mobilePay: MobilePayParameters) {
        self.init(amount: amount)
        
        self.acquirer = Acquires.mobilepayonline.rawValue
        
        self.extras = Dictionary<String,EncodableValue>()
        self.extras?[Acquires.mobilepay.rawValue] = EncodableValue(value: mobilePay.toEncodableDictionary())
    }
    
    public convenience init(amount: Int, vipps: VippsParameters) {
        self.init(amount: amount)
        
        self.acquirer = Acquires.vipps.rawValue
        
        self.extras = Dictionary<String,EncodableValue>()
        self.extras = vipps.toEncodableDictionary()
    }
}


public struct VippsParameters: Encodable {

    // MARK: - Properties

    public var return_url: String
    public var app_switch: Bool
    
    
    // MARK: Init
    
    public init(returnUrl: String) {
        self.return_url = returnUrl
        self.app_switch = true
    }
 
    
    // MARK: Convertion
    
    func toEncodableDictionary() -> Dictionary<String,EncodableValue> {
        var vippsDict = Dictionary<String,EncodableValue>()
        
        vippsDict["return_url"] = EncodableValue(value: self.return_url)
        vippsDict["app_switch"] = EncodableValue(value: self.app_switch)
        
        return vippsDict
    }
    
}


public struct MobilePayParameters: Encodable {

    // MARK: - Properties
    
    public var return_url: String
    public var language: String?
    public var shop_logo_url: String?

    
    // MARK: Init
    
    public init(returnUrl: String, language: String? = "da", shopLogoUrl: String? = nil) {
        self.return_url = returnUrl
        self.language = language
        self.shop_logo_url = shopLogoUrl
    }
    
    
    // MARK: Convertion
    
    func toEncodableDictionary() -> Dictionary<String,EncodableValue> {
        var mobilePayDict = Dictionary<String,EncodableValue>()
        
        mobilePayDict["return_url"] = EncodableValue(value: self.return_url)
        mobilePayDict["language"] = EncodableValue(value: self.language ?? "da")
        
        if let logoUrl = self.shop_logo_url {
            mobilePayDict["shop_logo_url"] = EncodableValue(value: logoUrl)
        }

        return mobilePayDict
    }
}
