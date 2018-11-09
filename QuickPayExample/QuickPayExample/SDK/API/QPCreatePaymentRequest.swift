//
//  File.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 07/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

class QPCreatePaymentRequest {
    
    // MARK: - Properties
    
    var headers: QPHeaders
    var parameters: QPCreatePaymentParameters

    
    // MARK: Init
    
    init(headers: QPHeaders, parameters: QPCreatePaymentParameters) {
        self.headers = headers
        self.parameters = parameters
    }
    
    
    // MARK: Request
    
    func sendRequestWithCompletionHandler(completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        guard let url = URL(string: "https://api.quickpay.net/payments"),
              let postData = try? JSONSerialization.data(withJSONObject: self.parameters.toDictionary(), options: []) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = postData
        request.setValue(headers.encodedAuthorization(), forHTTPHeaderField: "Authorization")
        request.setValue(String(format: "%lu", postData.count), forHTTPHeaderField: "Content-Length")
        request.setValue(headers.acceptVersion, forHTTPHeaderField: "Accept-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Create a memory-only session.
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)

         // Create a new data-task for the session, which queues the HTTP call
        let task = session.dataTask(with: request, completionHandler: completion)
        task.resume()
        
         // Tell the session to close down, and free all associated objects, once the data-task is completed.
        session.finishTasksAndInvalidate()
    }
}
