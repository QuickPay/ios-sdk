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

        #if DEBUG
        QuickPay.logDelegate = PrintLogger()
        #endif
        
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
