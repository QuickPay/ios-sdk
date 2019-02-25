//
//  HttpStatusCodes.swift
//  QuickPaySDK
//
//  Created on 29/01/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//
// The QuickPay API only operates with a subset of alle the HTTP status codes.
// https://learn.quickpay.net/tech-talk/api/#introduction

private let successStatusCodes = [QuickPayHttpStatusCodes.ok, QuickPayHttpStatusCodes.created, QuickPayHttpStatusCodes.accepted]

public enum QuickPayHttpStatusCodes: Int {
    // 200 Success
    case ok = 200
    case created
    case accepted

    // 400 Client Error
    case badRequest = 400
    case unauthorized
    case paymentRequired
    case forbidden
    case notFound
    case methodNotAllowed
    case notAcceptable
    case conflict = 409
    
    // 500 Server Error
    case internalServerError = 500
    
    
    // Utils
    
    /**
     Test if an Integer HTTP Status code is in the Success range defined in the QuickPay API
     */
    public static func isSuccessCode(statusCode: Int) -> Bool {
        if let quickPayStatus = QuickPayHttpStatusCodes(rawValue: statusCode) {
            return successStatusCodes.contains(quickPayStatus)
        }
        return false
    }
}
