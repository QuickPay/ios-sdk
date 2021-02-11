//
//  QPDefaultHeaders.swift
//  QuickPaySDK
//
//  Created on 06/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

class QPHeaders {
    
    // MARK: - Properties
    
    var acceptVersion: String {
        get {
            return "v10"
        }
    }
    var apiKey: String {
        get {
            return QuickPay.apiKey ?? ""
        }
    }

        
    // MARK: Auth
    
    func encodedAuthorization() -> String {
        let loginString = String(format: "%@:%@", "", apiKey)
        let loginData = loginString.data(using: String.Encoding.ascii)!
        let base64LoginString = loginData.base64EncodedString(options: .endLineWithLineFeed)

        return String(format: "Basic %@", base64LoginString)
    }
}
