//
//  EncodableValue.swift
//  QuickPaySDK
//
//  Created on 25/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public struct EncodableValue: Encodable {
    public var value: Encodable?
    
    public func encode(to encoder: Encoder) throws {
        try value?.encode(to: encoder)
    }
}
