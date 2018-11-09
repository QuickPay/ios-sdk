//
//  QPAddress.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

class QPAddress {

    // MARK: - Properties
    
    var name: String?
    var att: String?
    var street: String?
    var houseNumber: String?
    var houseExtension: String?
    var city: String?
    var zipCode: String?
    var region: String?
    var countryCode: String?
    var vatNo: String?
    var phoneNumber: String?
    var mobileNumber: String?
    var email: String?
    
    
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
