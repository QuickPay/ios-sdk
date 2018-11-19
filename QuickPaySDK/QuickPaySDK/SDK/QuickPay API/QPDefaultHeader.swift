//
//  QPDefaultHeaders.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 06/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPDefaultHeader: QPHeaders {
    
    // MARK: - Properties
    
    public var acceptVersion: String {
        get {
            return "v10"
        }
    }
    public var authorization: String

    
    // MARK: - Init
    
    public init(authorization: String) {
        self.authorization = authorization
    }
    
    
    // MARK: Auth
    
    public func encodedAuthorization() -> String {
        let loginString = String(format: "%@:%@", "", authorization)
        let loginData = loginString.data(using: String.Encoding.ascii)!
        let base64LoginString = loginData.base64EncodedString(options: .endLineWithLineFeed)

        return String(format: "Basic %@", base64LoginString)
    }
}
