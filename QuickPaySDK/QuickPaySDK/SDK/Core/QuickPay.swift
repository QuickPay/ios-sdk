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
                logDelegate?.log("\nQuickPay SDK has not been initialized, please do so before usage.\nQuickPay.initWith(authorization: \"<YOU_API_KEY>\")\n")
            }
            return _apiKey
        }
        set {
            _apiKey = newValue
        }
    }
    
    public static var logDelegate: LogDelegate?

    
    // MARK: Init
    
    private override init() {} // Only static access to the SDK
    
    public static func initWith(apiKey: String) {
        self.apiKey = apiKey
    }

    
    // MARK: API
    
    public static func openLink(paymentLink: QPPaymentLink, onCancel: @escaping () -> Void, onResponse: @escaping (Bool) -> Void) {
        QuickPay.openLink(url: paymentLink.url, onCancel: onCancel, onResponse: onResponse, animated: true, completion: nil)
    }
    
    public static func openLink(paymentLink: QPPaymentLink, onCancel: @escaping () -> Void, onResponse: @escaping (Bool) -> Void, animated: Bool, completion: (()->Void)?) {
        QuickPay.openLink(url: paymentLink.url, onCancel: onCancel, onResponse: onResponse, animated: animated, completion: completion)
    }
    
    public static func openLink(subscriptionLink: QPSubscriptionLink, onCancel: @escaping () -> Void, onResponse: @escaping (Bool) -> Void) {
        QuickPay.openLink(url: subscriptionLink.url, onCancel: onCancel, onResponse: onResponse, animated: true, completion: nil)
    }

    public static func openLink(subscriptionLink: QPSubscriptionLink, onCancel: @escaping () -> Void, onResponse: @escaping (Bool) -> Void, animated: Bool, completion: (()->Void)?) {
        QuickPay.openLink(url: subscriptionLink.url, onCancel: onCancel, onResponse: onResponse, animated: animated, completion: completion)
    }
    
    static func openLink(url: String, onCancel: @escaping () -> Void, onResponse: @escaping (Bool) -> Void, animated: Bool, completion: (()->Void)?) {
        OperationQueue.main.addOperation {
            let mainController = UIApplication.shared.keyWindow?.rootViewController
            
            let controller = QPPaymentWindowController()
            controller.gotoUrl = url
            controller.onCancel = onCancel
            controller.onResponse = onResponse
            
            let navController = UINavigationController(rootViewController: controller)
            
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: controller, action: #selector(controller.cancel))
            
            mainController?.present(navController, animated: animated, completion: completion)
        }
    }
    
    static func canOpenUrl(url: String) -> Bool {
        guard let url = URL(string: url) else {
            return false
        }

        return canOpenUrl(url: url)
    }

    static func canOpenUrl(url: URL) -> Bool {
        var canOpen = false
        
        if Thread.isMainThread {
            canOpen = UIApplication.shared.canOpenURL(url)
        }
        else {
            DispatchQueue.main.sync {
                canOpen = UIApplication.shared.canOpenURL(url)
            }
        }
        
        return canOpen
    }

    
    // MARK: Notifications
    
    static func startObservingLifecycle() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }
    
    static func stopObserveringLifecycle() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    @objc static func applicationDidBecomeActive() {
        startObservingLifecycle()
        onCallbackFromMobilePay()
    }

}

// MARK: - MobilePay Online
public extension QuickPay {
    
    //MARK: Properties
    
    private static let mobilePayOnlineScheme = "mobilepayonline://"
    private static let mobilePayUrlSource = "com.danskebank.mobilepay" // The source URL when the app is opened by MobilePay
    
    private static var mobilePayCompletion: ((_ payment: QPPayment) -> Void)?
    private static var mobilePayFailure: (() -> Void)?
    private static var mobilePayPayment: QPPayment?
    
    
    // MARK: API
    
    public static func authorizeWithMobilePay(payment: QPPayment, completion: ((_ payment: QPPayment) -> Void)?, failure: (() -> Void)?) {
        guard let mobilePayToken = payment.operations?[0].data?["session_token"] else {
            QuickPay.logDelegate?.log("The operations of the Payment does not contain the needed information to authorize through MobilePay")
            failure?()
            return
        }
        
        if let mobilePayUrl = URL(string: "\(mobilePayOnlineScheme)online?sessiontoken=\(mobilePayToken)&version=2") {
            if canOpenUrl(url: mobilePayUrl) {
                if completion != nil {
                    mobilePayCompletion = completion
                    mobilePayFailure = failure
                    mobilePayPayment = payment
                    
                    startObservingLifecycle()
                }
                
                OperationQueue.main.addOperation {
                    UIApplication.shared.open(mobilePayUrl)
                }
                
                return
            }
            else {
                QuickPay.logDelegate?.log("Cannot open MobilePay App.")
                QuickPay.logDelegate?.log("Make sure the 'mobilepayonline' URL Scheme is added to your plist and make sure the MobilePay App is installed on the users phone before presenting this payment option.")
                QuickPay.logDelegate?.log("You can test if MobilePay can be opened by calling QuickPay.mobilePayAvailable()")
            }
        }
        
        failure?()
    }
    
    static func onCallbackFromMobilePay() {
        guard let payment = mobilePayPayment, let completion = mobilePayCompletion else {
            mobilePayFailure?()
            
            mobilePayCompletion = nil
            mobilePayFailure = nil
            mobilePayPayment = nil
            return
        }

        completion(payment)

        mobilePayCompletion = nil
        mobilePayFailure = nil
        mobilePayPayment = nil
    }
    
    public static func mobilePayAvailable() -> Bool {
        return canOpenUrl(url: mobilePayOnlineScheme)
    }
    
}
