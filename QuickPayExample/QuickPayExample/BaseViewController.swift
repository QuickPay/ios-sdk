//
//  BaseViewController.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 06/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        styleNavigationBar()
    }
    
    private func styleNavigationBar() {
        let navigationBarImage = UIImageView(image: UIImage(named: "Logo Inverse"))
        navigationBarImage.contentMode = .scaleAspectFit
        self.navigationItem.titleView = navigationBarImage
    }
    
}
