//
//  URLExtensions.swift
//  QuickPaySDK
//
//  Created on 11/02/2021
//  Copyright © 2021 QuickPay. All rights reserved.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
