//
//  QuickPaySDK.swift
//  QuickPaySDK
//
//  Created on 06/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import PassKit
import Foundation
import UIKit

public enum Presentation {
    case present(controller: UIViewController, animated: Bool, completion: (()->Void)?)
    case push(navigationController: UINavigationController, animated: Bool)
}

public protocol InitializeDelegate {
    
    func initializationStarted()
    func initializationCompleted()
    
}

public class QuickPay: NSObject {
    
    // MARK: Properties

    public static private(set) var isMobilePayOnlineEnabled: Bool?
    public static private(set) var isApplePayEnabled: Bool?
    public static private(set) var isVippsEnabled: Bool?
    public static private(set) var isInitializing: Bool = true

    internal static let sdkBundleIdentifier = "net.quickpay.quickpaysdk"
    private static var _apiKey: String?
    static private(set) var apiKey: String? {
        get {
            if _apiKey == nil {
                logDelegate?.log("\nQuickPay SDK has not been initialized, please do so before usage.\nQuickPay.initWith(authorization: \"<API_KEY>\")\n")
            }
            return _apiKey
        }
        set {
            _apiKey = newValue
        }
    }
    
    public static var logDelegate: LogDelegate? = PrintLogger()
    public static var initializeDelegate: InitializeDelegate?

    
    // MARK: Init
    
    private override init() {} // Only static access to the SDK
    
    public static func initWith(apiKey: String) {
        self.apiKey = apiKey
        fetchAquires()
    }
    
    public static func fetchAquires() {
        isInitializing = true
        initializeDelegate?.initializationStarted()

        let dispatchGroup = DispatchGroup();

        dispatchGroup.enter()
        isMobilePayOnlineEnabled { (enabled) in
            isMobilePayOnlineEnabled = enabled
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        isApplePayEnabled { (enabled) in
            isApplePayEnabled = enabled
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        isVippsEnabled { (enabled) in
            isVippsEnabled = enabled
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .global(qos: DispatchQoS.QoSClass.background)) {
            isInitializing = false
            initializeDelegate?.initializationCompleted()
        }
    }
    
    
    // MARK: API
    
    public static func openPaymentLink(paymentUrl: String, onCancel: @escaping () -> Void, onResponse: @escaping (Bool) -> Void, presentation: Presentation) {
        OperationQueue.main.addOperation {
            let paymentController = QPPaymentWindowController(paymentUrl: paymentUrl)

            let delegate = QPPaymentWindowControllerDelegateCallbacksWrapper()
            delegate.onResponse = onResponse
            paymentController.delegate = delegate
            
            switch presentation {
            case .push(let navController, let animated):
                navController.pushViewController(paymentController, animated: animated)

                delegate.onCancel = {
                    OperationQueue.main.addOperation {
                        navController.popViewController(animated: animated)
                        onCancel()
                    }
                }

            case .present(let presenter, let animated, let completion):
                let navController = UINavigationController(rootViewController: paymentController)
                
                delegate.onCancel = {
                    OperationQueue.main.addOperation {
                        navController.dismiss(animated: animated, completion: nil)
                        onCancel()
                    }
                }
                
                paymentController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: paymentController, action: #selector(paymentController.cancel))
                presenter.present(navController, animated: animated, completion: completion)
            }
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
        
        DispatchQueue.mainSyncSafe {
            canOpen = UIApplication.shared.canOpenURL(url)
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
    
    static func stopObservingLifecycle() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    @objc static func applicationDidBecomeActive() {
        stopObservingLifecycle()
        onCallbackFromMobilePay()
    }

}


// MARK: - MobilePay Online
public extension QuickPay {
    
    //MARK: Properties
    
    private static let mobilePayOnlineScheme = "mobilepayonline://"
    private static let mobilePayUrlSource = "com.danskebank.mobilepay" // The source URL when the app is opened by MobilePay
    
    private static let vippsScheme = "vipps://"
    
    private static var mobilePayCompletion: ((_ payment: QPPayment) -> Void)?
    private static var mobilePayFailure: (() -> Void)?
    private static var mobilePayPayment: QPPayment?
    
    
    // MARK: API
    
    static func authorizeWithMobilePay(payment: QPPayment, completion: ((_ payment: QPPayment) -> Void)?, failure: (() -> Void)?) {
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
    
}


// MARK: - Capabilities

// Apple
extension QuickPay {
    
    static func isApplePayEnabled(completion: @escaping (_ enabled: Bool)->Void) {
        QPGetAcquireSettingsClearhausRequest().sendRequest(success: { (settings) in
            completion(settings.active && settings.apple_pay)
        }) { (data, response, error) in
            completion(false)
        }
    }
    
    public static func isApplePayAvailableOnDevice() -> Bool {
        return PKPaymentAuthorizationController.canMakePayments()
    }
    
}

// MobilePay
extension QuickPay {
    
    static func isMobilePayOnlineEnabled(completion: @escaping (_ enabled: Bool)->Void) {
        QPGetAcquireSettingsMobilePayRequest().sendRequest(success: { (settings) in
            completion(settings.active)
        }) { (data, response, error) in
            completion(false)
        }
    }

    public static func isMobilePayAvailableOnDevice() -> Bool {
        return canOpenUrl(url: mobilePayOnlineScheme)
    }
    
}

// Vipps
extension QuickPay {
    
    static func isVippsEnabled(completion: @escaping (_ enabled: Bool)->Void) {
        QPGetAcquireSettingsVippsRequest().sendRequest(success: { (settings) in
            completion(settings.active)
        }) { (data, response, error) in
            completion(false)
        }
    }

    
    public static func isVippsAvailableOnDevice() -> Bool {
        return canOpenUrl(url: vippsScheme)
    }
    
}
