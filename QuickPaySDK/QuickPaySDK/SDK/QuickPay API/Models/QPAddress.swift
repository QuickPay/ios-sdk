//
//  QPAddress.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPAddress {

    // MARK: - Properties
    
    public var name: String?
    public var att: String?
    public var street: String?
    public var houseNumber: String?
    public var houseExtension: String?
    public var city: String?
    public var zipCode: String?
    public var region: String?
    public var countryCode: String?
    public var vatNo: String?
    public var phoneNumber: String?
    public var mobileNumber: String?
    public var email: String?
    
    
    // MARK: - Init
    
    public init() {
        
    }

        
    // MARK: - JSON
    
    public func toDictionary() -> Dictionary<String, Any> {
        var dict: Dictionary = Dictionary<String, Any>()
        
        dict["name"] = name
        dict["att"] = att
        dict["street"] = street
        dict["house_number"] = houseNumber
        dict["house_extension"] = houseExtension
        dict["city"] = city
        dict["zip_code"] = zipCode
        dict["region"] = region
        dict["country_code"] = countryCode
        dict["vat_no"] = vatNo
        dict["phone_number"] = phoneNumber
        dict["mobile_number"] = mobileNumber
        dict["email"] = email
        
        return dict
    }
}
