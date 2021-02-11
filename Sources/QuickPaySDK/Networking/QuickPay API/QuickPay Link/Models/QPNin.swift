//
//  QPNin.swift
//  QuickPaySDK
//
//  Created on 04/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class QPNin: Codable {

    // MARK: - Enums
    
    private enum Gender: String {
        case male
        case female
    }
    
    
    // MARK: - Properties
    
    public var number: String?
    public var country_code: String?
    public var gender: String? //TODO: Convert this into the Gender enum
    
}
