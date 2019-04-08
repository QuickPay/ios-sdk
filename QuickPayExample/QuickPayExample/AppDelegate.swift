//
//  AppDelegate.swift
//  QuickPayExample
//
//  Created on 06/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import UIKit
import QuickPaySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Init the SDK with your API key
        QuickPay.initWith(apiKey: "f1a4b80189c73862655552d06f9419dd7574c65de916fef88cf9854f6907f1b4")

        // Optionally you can attach a LogDelegate to the static QuickPay class in order to recieve additional error messages.
        // This will be very helpful in your debugging procedures
        #if DEBUG
        QuickPay.logDelegate = PrintLogger()
        #endif

        // This is only nessesary in this example app because the PaymentView is displayed
        // before the SDK has had a change to communicate with the QuickPay API to determine
        // which paymenet methods are available.
        while QuickPay.isInitializing {
            sleep(1)
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {

    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {

    }

    func applicationWillTerminate(_ application: UIApplication) {

    }
    
}
