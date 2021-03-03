//
//  DispatchQueueExtensions.swift
//  QuickPaySDK
//
//  Created on 20/09/2019
//  Copyright © 2019 QuickPay. All rights reserved.
//

import Foundation

extension DispatchQueue {

    class func mainSyncSafe(execute work: () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
    
}
