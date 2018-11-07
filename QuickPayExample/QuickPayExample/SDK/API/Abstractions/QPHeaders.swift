//
//  QPHeader.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

protocol QPHeaders {
    var acceptVersion: String? {get}
    var authorization: String? {get}
}
