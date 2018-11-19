//
//  QPPayment.swift
//  QuickPaySDK
//
//  Created by Steffen Lund Andersen on 16/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

public class QPPayment : Codable {
    
    // MARK: - Properties
    
    public let id: Int
    public let merchantId: Int
    public let orderId: String
    public let accepted: Bool
    public let type: String
    public let textOnStatement: String
    public let brandingId: String?
    public let currency: String
    public let state: String
    public let testMode: Bool
    public let acquirer: String
    public let facilitator: String?
    public let createdAt: String
    public let updatedAt: String
    public let retentedAt: String?
    public let balance: Int
    public let fee: Int?
    public let deadlineAt: String?
    
    
    // MARK: Codable
    
    public enum CodingKeys: String, CodingKey {
        case id
        case merchantId         = "merchant_id"
        case orderId            = "order_id"
        case accepted
        case type
        case textOnStatement    = "text_on_statement"
        case brandingId			= "branding_id"
        case currency
        case state
        case testMode			= "test_mode"
        case acquirer
        case facilitator
        case createdAt			= "created_at"
        case updatedAt			= "updated_at"
        case retentedAt			= "retented_at"
        case balance
        case fee
        case deadlineAt			= "deadline_at"
    }
}

/*
 "variables": {},
 "metadata": {
 "type": "card",
 "origin": "form",
 "brand": "visa",
 "bin": "100000",
 "corporate": false,
 "last4": "0008",
 "exp_month": 12,
 "exp_year": 2020,
 "country": "DNK",
 "is_3d_secure": true,
 "issued_to": null,
 "hash": "d345e9e91c4b46f938662OPLLTi62vFneUKsDCBun44b7FxhUhG",
 "number": null,
 "customer_ip": "194.19.204.18",
 "customer_country": "DK",
 "fraud_suspected": true,
 "fraud_remarks": [
 "Flagged because FraudFilter rule set \"mpo test\" (id: 46951) triggered.",
 "Flagged because FraudFilter rule set \"Fraudfilter score at least 50 (default)\" (id: 3) triggered."
 ],
 "fraud_reported": false,
 "fraud_report_description": null,
 "fraud_reported_at": null,
 "nin_number": null,
 "nin_country_code": null,
 "nin_gender": null,
 "shopsystem_name": null,
 "shopsystem_version": null
 },
 "link": {
 "url": "https://payment.quickpay.net/payments/239cca2594e9cdd7af85b7fb5dfe3d95487f0afa76eb792a7827f5027367a687",
 "agreement_id": 11,
 "language": "en",
 "amount": 4200,
 "continue_url": "https://qp.payment.success",
 "cancel_url": "https://qp.payment.failure",
 "callback_url": null,
 "payment_methods": "creditcard,mobilepay",
 "auto_fee": false,
 "auto_capture": null,
 "branding_id": null,
 "google_analytics_client_id": null,
 "google_analytics_tracking_id": null,
 "version": "v10",
 "acquirer": null,
 "deadline": null,
 "framed": false,
 "branding_config": {},
 "invoice_address_selection": null,
 "shipping_address_selection": null,
 "customer_email": null
 },
 "shipping_address": null,
 "invoice_address": {
 "name": "CV",
 "att": null,
 "street": null,
 "city": "Aarhus",
 "zip_code": null,
 "region": null,
 "country_code": "DNK",
 "vat_no": null,
 "company_name": null,
 "house_number": null,
 "house_extension": null,
 "phone_number": null,
 "mobile_number": null,
 "email": null
 },
 "basket": [
 {
 "qty": 1,
 "item_no": "123",
 "item_name": "White Dress",
 "item_price": 42,
 "vat_rate": 0.25
 }
 ],
 "shipping": null,
 "operations": [
 {
 "id": 1,
 "type": "authorize",
 "amount": 4200,
 "pending": false,
 "qp_status_code": "30100",
 "qp_status_msg": "3D Secure is required by FraudFilter rule set: \"mpo test\" (id: 46951)",
 "aq_status_code": null,
 "aq_status_msg": null,
 "data": {},
 "callback_url": null,
 "callback_success": null,
 "callback_response_code": null,
 "callback_duration": null,
 "acquirer": "clearhaus",
 "3d_secure_status": null,
 "callback_at": null,
 "created_at": "2018-11-19T14:26:08Z"
 },
 {
 "id": 2,
 "type": "authorize",
 "amount": 4200,
 "pending": false,
 "qp_status_code": "30100",
 "qp_status_msg": "3D Secure is required by FraudFilter rule set: \"mpo test\" (id: 46951)",
 "aq_status_code": null,
 "aq_status_msg": null,
 "data": {},
 "callback_url": null,
 "callback_success": null,
 "callback_response_code": null,
 "callback_duration": null,
 "acquirer": "clearhaus",
 "3d_secure_status": null,
 "callback_at": null,
 "created_at": "2018-11-19T14:26:31Z"
 },
 {
 "id": 3,
 "type": "authorize",
 "amount": 4200,
 "pending": false,
 "qp_status_code": "20000",
 "qp_status_msg": "Approved",
 "aq_status_code": "20000",
 "aq_status_msg": "Approved",
 "data": {},
 "callback_url": null,
 "callback_success": null,
 "callback_response_code": null,
 "callback_duration": null,
 "acquirer": "clearhaus",
 "3d_secure_status": "Y",
 "callback_at": null,
 "created_at": "2018-11-19T14:26:35Z"
 }
 ],
 */
