//
//  ViewController.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 06/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import UIKit
import  WebKit

class ExampleViewController: BaseViewController, WKNavigationDelegate {
    
    // MARK: - IBActions
    @IBAction func doPayment(_ sender: Any) {
        QuickPaySDK.testStuff()
    }
    
}
