//
//  QuickPaySDK.swift
//  QuickPaySDK
//
//  Created on 06/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation
import UIKit

public class QuickPay {
    
    // MARK: Properties

    private static var _authorization: String?
    static var authorization: String? {
        get {
            if _authorization == nil {
                print("QuickPay SDK has not been initialised. Please execute QuickPay.initWith(authorization: <YOU_API_KEY>)")
            }
            
            return _authorization
        }
        set {
            _authorization = newValue
        }
    }
    
    
    // MARK: Init
    
    // Only static access to the SDK
    private init() {

    }
    
    public static func initWith(authorization: String) {
        self.authorization = authorization
    }

    
    // MARK: API
    
    public static func openLink(url: String, cancelHandler: @escaping () -> Void, responseHandler: @escaping (Bool) -> Void) {
        let mainController = UIApplication.shared.keyWindow?.rootViewController
        
        let controller = QPViewController()
        controller.gotoUrl = url
        controller.onCancel = cancelHandler
        controller.onResponse = responseHandler
        
        let navController = UINavigationController(rootViewController: controller)
        
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: controller, action: #selector(controller.cancel))
        
        mainController?.present(navController, animated: true, completion: nil)
    }
}
