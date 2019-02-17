//
//  QPOperation.swift
//  QuickPaySDK
//
//  Created on 07/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPOperation : Codable {
    
    // MARK: - Properties
    
    public var id: Int
    public var type: String?
    public var amount: Int?
    public var pending: Bool?
    public var qp_status_code: String?
    public var qp_status_msg: String?
    public var aq_status_msg: String?
    public var aqStatusMsg: String?
    public var data: Dictionary<String, String>?
    public var callback_url: String?
    public var callback_success: Bool?
    public var callback_response_code: Int?
    public var callback_duration: Int?
    public var acquirer: String?
    public var callback_at: String?
    public var created_at: String?
    
}
