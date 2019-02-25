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
    
    private static var _apiKey: String?
    static private(set) var apiKey: String? {
        get {
            if _apiKey == nil {
                logger?.log("\nQuickPay SDK has not been initialized, please do so before usage.\nQuickPay.initWith(authorization: \"<YOU_API_KEY>\")\n")
            }
            return _apiKey
        }
        set {
            _apiKey = newValue
        }
    }
    
    public static var logger: LogDelegate?

    
    // MARK: Init
    
    private override init() {} // Only static access to the SDK
    
    public static func initWith(apiKey: String) {
        self.apiKey = apiKey
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
//            controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: controller, action: #selector(controller.printHTML))
            
            mainController?.present(navController, animated: animated, completion: completion)
        }
    }
    
    // Test if the different payment apps are available

    static func canOpenUrl(url: String) -> Bool {
        guard let url = URL(string: url) else {
            return false
        }

        return canOpenUrl(url: url)
    }

    static func canOpenUrl(url: URL) -> Bool {
        var canOpen = false
        DispatchQueue.main.sync {
            canOpen = UIApplication.shared.canOpenURL(url)
        }
        
        return canOpen
    }

    
    // MARK: Lifecycle
    
    public static func application(open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) {
        if let urlSource = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String {
            switch(urlSource) {
            case mobilePayUrlSource: onCallbackFromMobilePay(); break
            default: break
            }
        }
    }
}

// MARK: - MobilePay Online
public extension QuickPay {
    
    //MARK: Properties
    
    private static let mobilePayOnlineScheme = "mobilepayonline://"
    private static let mobilePayUrlSource = "com.danskebank.mobilepay" // The source URL when the app is opened by MobilePay
    
    private static var mobilePayCompletion: ((_ accepted: Bool) -> Void)?
    private static var mobilePayPayment: QPPayment?
    
    
    // MARK: API
    
    public static func authorizeWithMobilePay(payment: QPPayment, completion: @escaping (_ accepted: Bool) -> Void) {
        guard let mobilePayToken = payment.operations?[0].data?["session_token"] else {
            QuickPay.logger?.log("The operations of the Payment does not contain the needed information to authorize through MobilePay")
            completion(false)
            return
        }
        
        if let mobilePayUrl = URL(string: "\(mobilePayOnlineScheme)online?sessiontoken=\(mobilePayToken)&version=2") {
            if canOpenUrl(url: mobilePayUrl) {
                mobilePayCompletion = completion
                mobilePayPayment = payment
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.open(mobilePayUrl)
                }
                
                return
            }
            else {
                QuickPay.logger?.log("Cannot open MobilePay App.")
                QuickPay.logger?.log("Make sure the 'mobilepayonline' URL Scheme is added to your plist and make sure the MobilePay App is installed on the users phone before presenting this payment option.")
                QuickPay.logger?.log("You can test if MobilePay can be opened by calling QuickPay.mobilePayAvailable()")
            }
        }
        
        completion(false)
    }
    
    static func onCallbackFromMobilePay() {
        if let payment = mobilePayPayment {
            let getPaymentRequest = QPGetPaymentRequest(id: payment.id)
            
            getPaymentRequest.sendRequest(success: { (payment) in
                mobilePayCompletion?(payment.accepted)
                mobilePayCompletion = nil
                mobilePayPayment = nil
            }) { (data, response, error) in
                mobilePayCompletion?(false)
                mobilePayCompletion = nil
                mobilePayPayment = nil
            }
        }
        else {
            mobilePayCompletion?(false)
        }

    }
    
    public static func mobilePayAvailable() -> Bool {
        return canOpenUrl(url: mobilePayOnlineScheme)
    }
    
}
