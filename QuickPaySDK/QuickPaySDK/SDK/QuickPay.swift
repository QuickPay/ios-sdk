//
//  QuickPaySDK.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 06/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation
import UIKit

public class QuickPay {
    // Only static access to the SDK
    private init() {
        
    }
    
    public class func openLink(url: String, cancelHandler: @escaping () -> Void, responseHandler: @escaping (Bool) -> Void) {
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
