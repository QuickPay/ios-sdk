//
//  QuickPaySDK.swift
//  QuickPaySDK
//
//  Created on 06/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation
import UIKit

public class QuickPay: NSObject {
    
    // MARK: Properties
    
    
    private static var _authorization: String?
    static private(set) var authorization: String? {
        get {
            if _authorization == nil {
                fatalError("QuickPay SDK has not been initialized, please do so before usage.\nQuickPay.initWith(authorization: <YOU_API_KEY>)")
            }
            return _authorization
        }
        set {
            _authorization = newValue
        }
    }
    
    
    // MARK: Init
    
    
    // Only static access to the SDK
    private override init() {}
    
    public static func initWith(authorization: String) {
        self.authorization = authorization
    }
    
    
    // MARK: API
    
    public static func openLink(paymentLink: QPPaymentLink, cancelHandler: @escaping () -> Void, responseHandler: @escaping (Bool) -> Void) {
        QuickPay.openLink(url: paymentLink.url, cancelHandler: cancelHandler, responseHandler: responseHandler, animated: true, completion: nil)
    }
    
    public static func openLink(paymentLink: QPPaymentLink, cancelHandler: @escaping () -> Void, responseHandler: @escaping (Bool) -> Void, animated: Bool, completion: (()->Void)?) {
        QuickPay.openLink(url: paymentLink.url, cancelHandler: cancelHandler, responseHandler: responseHandler, animated: animated, completion: completion)
    }
    
    public static func openLink(subscriptionLink: QPSubscriptionLink, cancelHandler: @escaping () -> Void, responseHandler: @escaping (Bool) -> Void) {
        QuickPay.openLink(url: subscriptionLink.url, cancelHandler: cancelHandler, responseHandler: responseHandler, animated: true, completion: nil)
    }

    public static func openLink(subscriptionLink: QPSubscriptionLink, cancelHandler: @escaping () -> Void, responseHandler: @escaping (Bool) -> Void, animated: Bool, completion: (()->Void)?) {
        QuickPay.openLink(url: subscriptionLink.url, cancelHandler: cancelHandler, responseHandler: responseHandler, animated: animated, completion: completion)
    }
    
    internal static func openLink(url: String, cancelHandler: @escaping () -> Void, responseHandler: @escaping (Bool) -> Void, animated: Bool, completion: (()->Void)?) {
        OperationQueue.main.addOperation {
            let mainController = UIApplication.shared.keyWindow?.rootViewController
            
            let controller = QPViewController()
            controller.gotoUrl = url
            controller.onCancel = cancelHandler
            controller.onResponse = responseHandler
            
            let navController = UINavigationController(rootViewController: controller)
            
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: controller, action: #selector(controller.cancel))
            controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: controller, action: #selector(controller.printHTML))
            
            mainController?.present(navController, animated: animated, completion: completion)
        }
    }
}
