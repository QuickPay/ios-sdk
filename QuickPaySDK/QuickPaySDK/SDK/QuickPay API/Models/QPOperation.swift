//
//  QPOperation.swift
//  QuickPaySDK
//
//  Created by Steffen Lund Andersen on 16/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPOperation {
    
    // MARK: - Properties
    
    public var id: Int?
    public var type: Int?
    public var amount: Int?
    public var pending: Int?
    public var qpStatusCode: String?
    public var qpStatusMsg: String?
    public var aqStatusCode: String?
    public var aqStatusMsg: String?
    public var data: Dictionary<String, Any>?
    public var callbackUrl: String?
    public var callbackSuccess: Int?
    public var callbackResponseCode: Int?
    public var callbackDuration: Int?
    public var acquirer: String?
    public var callbackAt: String?
    public var createdAt: String?
}
