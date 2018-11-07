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
    
    public var acceptVersion: String? {
        get {
            return "v10"
        }
    }
    public var authorization: String?

    
    // MARK: - Init
    
    init(authorization: String) {
        self.authorization = authorization
    }
}

