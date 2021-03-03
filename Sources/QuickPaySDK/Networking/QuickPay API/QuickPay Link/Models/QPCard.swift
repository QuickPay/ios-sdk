//
//  QPCard.swift
//  QuickPaySDK
//
//  Created on 04/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation
import PassKit

public class QPCard: Codable {
    
    // MARK: - Enums
    
    private enum CardBrands: String { // This enum is private until we handle the brands as enums instead of just a string
        case americanExpress = "american-express"
        case dankort = "dankort"
        case diners = "diners"
        case fbg1886 = "fbg1886"
        case jcb = "jcb"
        case maestro = "maestro"
        case mastercard = "mastercard"
        case mastercardDebet = "mastercard-debet"
        case visa = "visa"
        case visaElectron = "visa-electron"
    }
    
    
    // MARK: - Properties
    
    public var number: String?
    public var expiration: String?
    public var cvd: String?
    public var token: String?
    public var apple_pay_token: QPApplePayToken?
    public var issued_to: String?
    public var brand: String? // TODO: Convert this to an array of enums instead
    public var status: String?
    public var eci: String?
    public var xav: String?
    public var cavv: String?
    
    
    // MARK: - Init
    
    public init() {
        
    }
    
    convenience public init(applePayToken: PKPaymentToken) {
        self.init()
        self.apple_pay_token = QPApplePayToken(pkPaymentToken: applePayToken)
    }
}
