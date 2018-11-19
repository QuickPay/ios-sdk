//
//  QPGeneratePaymentLinkParameters.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 12/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPGeneratePaymentLinkParameters {
    
    // MARK: - Properties

    public var id: Int?
    public var amount: Double?
    public var agreementId: Int?
    public var language: String?
    public var continueUrl: String?
    public var cancelUrl: String?
    public var callbackUrl: String?
    public var paymentMethods: String?
    public var autoFee: Bool?
    public var brandingId: Int?
    public var googleAnalyticsTrackingId: String?
    public var googleAnalyticsClientId: String?
    public var acquirer: String?
    public var deadline: String?
    public var framed: Int?
    public var brandingConfig: Dictionary<String, Any>? = Dictionary<String, Any>()
    public var vatAmount: Int?
    public var category: String?
    public var referenceTitle: String?
    public var productId: String?
    public var customerEmail: String?
    public var autoCapture: Int?
    public var additionalParameters: Dictionary<String, Any>? = Dictionary<String, Any>()
    
    
    // MARK: Init
    
    public init() {
        
    }
    
    
    // MARK: - JSON
    
    public func toDictionary() -> Dictionary<String, Any> {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict["id"] 								= id
        dict["amount"] 							= amount
        dict["agreement_id"] 					= agreementId
        dict["language"] 						= language
        dict["continue_url"] 					= continueUrl
        dict["cancel_url"] 						= cancelUrl
        dict["callback_url"] 					= callbackUrl
        dict["payment_methods"] 			 	= paymentMethods
        dict["auto_fee"] 					 	= autoFee
        dict["branding_id"]                  	= brandingId
        dict["google_analytics_tracking_id"] 	= googleAnalyticsTrackingId
        dict["google_analytics_client_id"]   	= googleAnalyticsClientId
        dict["acquirer"]                     	= acquirer
        dict["deadline"]                     	= deadline
        dict["framed"]						 	= framed
        dict["branding_config"]              	= brandingConfig
        dict["google_analytics_tracking_id"] 	= googleAnalyticsTrackingId
        dict["vat_amount"] 						= vatAmount
        dict["category"] 						= category
        dict["reference_title"] 				= referenceTitle
        dict["product_id"] 						= productId
        dict["customer_email"] 					= customerEmail
        dict["auto_capture"] 					= autoCapture
        
        additionalParameters?.forEach { (k,v) in dict[k] = v }
        
        return dict
    }
}
