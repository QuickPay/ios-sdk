//
//  QPAddress.swift
//  QuickPaySDK
//
//  Created on 07/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPAddress : Codable {

    // MARK: - Properties
    
    public var name: String?
    public var att: String?
    public var street: String?
    public var city: String?
    public var zip_code: String?
    public var region: String?
    public var country_code: String?
    public var vat_no: String?
    public var company_name: String?
    public var house_number: String?
    public var house_extension: String?
    public var phone_number: String?
    public var mobile_number: String?
    public var email: String?
    

    // MARK: Init
    
    public init() {
        
    }
    
}
