//
//  QPMetadata.swift
//  QuickPaySDK
//
//  Created on 20/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPMetadata : Codable {
    
    // MARK:  - Properties
    
    public var type: String?
    public var origin: String?
    public var brand: String?
    public var bin: String?
    public var corporate: Bool?
    public var last4: String?
    public var exp_month: Int?
    public var exp_year: Int?
    public var country: String?
    public var is_3d_secure: Bool?
    public var issued_to: String?
    public var hash: String?
    public var number: String?
    public var customer_ip: String?
    public var customer_country: String?
    public var fraud_suspected: Bool?
    public var fraud_remarks: Array<String>?
    public var fraud_reported: Bool?
    public var fraud_report_description: String?
    public var fraud_reported_at: String?
    public var nin_number: String?
    public var nin_country_code: String?
    public var nin_gender: String?
    public var shopsystem_name: String?
    public var shopsystem_version: String?
    
}
