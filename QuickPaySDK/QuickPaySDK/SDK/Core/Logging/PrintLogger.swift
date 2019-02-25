//
//  ConsoleLogger.swift
//  QuickPaySDK
//
//  Created on 25/02/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

public class PrintLogger {

    public init() {
        
    }
    
}

extension PrintLogger: LogDelegate {

    public func log(_ msg: Any) {
        OperationQueue.main.addOperation {
            print(msg)
        }
    }
    
}
