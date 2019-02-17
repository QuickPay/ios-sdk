//
//  QPApplePayToken.swift
//  QuickPaySDK
//
//  Created on 04/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation
import PassKit

public class QPApplePayToken: Codable {
    
    // MARK: - Properties
    public let paymentData: QPPaymentData
    public let transactionIdentifier: String
    public let paymentMethod: QPApplePayPaymentMethod
    
    // MARK: - Init
    
    public init(pkPaymentToken: PKPaymentToken) {
        self.transactionIdentifier = pkPaymentToken.transactionIdentifier
        self.paymentMethod = QPApplePayPaymentMethod(pkPaymentMethod: pkPaymentToken.paymentMethod)

        do {
            paymentData = try JSONDecoder().decode(QPPaymentData.self, from: pkPaymentToken.paymentData)
        }
        catch {
            fatalError("Could not parse PKPaymentData")
        }
    }
}

public class QPPaymentData: Codable {
    
    // MARK: - Properties
    
    public var version: String?
    public var data: String?
    public var header: QPPaymentHeader?
    public var signature: String?
}

public class QPPaymentHeader: Codable {
    
    // MARK: - Properties
    
    public var ephemeralPublicKey: String?
    public var publicKeyHash: String?
    public var transactionId: String?
    
}


public class QPApplePayPaymentMethod: Codable {
    
    // MARK: - Properties
    
    public let displayName: String?
    public let network: String?
    public let type: String?
//    var paymentPass: PKPaymentPass?
    
    // MARK: - Init
    
    public init(pkPaymentMethod: PKPaymentMethod) {
        self.displayName = pkPaymentMethod.displayName
        self.network = pkPaymentMethod.network?.rawValue
        self.type = pkPaymentMethod.type.stringRepresentation()
    }
}

extension PKPaymentMethodType {
    
    func stringRepresentation() -> String {
        switch self {
        case PKPaymentMethodType.debit:
            return "debit"
        case PKPaymentMethodType.credit:
            return "credit"
        case PKPaymentMethodType.prepaid:
            return "prepaid"
        case PKPaymentMethodType.store:
            return "store"
        default:
            return "unknown"
        }
    }
}
