//
//  UIColorExtensions.swift
//  QuickPayExample
//
//  Created on 17/03/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(integerLiteral: red)/255.0, green: CGFloat(integerLiteral: green)/255.0, blue: CGFloat(integerLiteral: blue)/255.0, alpha: 1.0)
    }
    
}
