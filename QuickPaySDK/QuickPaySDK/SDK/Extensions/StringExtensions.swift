//
//  StringExtensions.swift
//  QuickPaySDK
//
//  Created on 17/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//
//  Inspired by
//  https://stackoverflow.com/questions/31859185/how-to-convert-a-base64string-to-string-in-swift

import Foundation

extension String {
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }
    
    func base64Decoded() -> String? {
        var st = self;
        if (self.count % 4 <= 2){
            st += String(repeating: "=", count: (self.count % 4))
        }
        guard let data = Data(base64Encoded: st) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
}
