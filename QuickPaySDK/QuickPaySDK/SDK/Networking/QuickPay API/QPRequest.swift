//
//  QPRequest.swift
//  QuickPaySDK
//
//  Created on 16/11/2018
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation


/**
 QPRequest handles the real request and parse the JSON response
 */
public class QPRequest {
    
    // MARK: - Properties
    
    internal let quickPayAPIBaseUrl = "https://api.quickpay.net"
    internal let headers = QPHeaders()
    
    
    // MARK: - URL Request
    
    internal func sendRequest<T: Decodable>(request: URLRequest, success: @escaping (_ result: T) -> Void, failure: ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)?) {
        // Create a memory-only session.
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        // Create a new data-task for the session, which queues the HTTP call and parse the response
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                failure?(data, response, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                failure?(data, response, error)
                return
            }
            
            // If HTTP Success state we parse the result into the corresponding API Model
            if(QuickPayHttpStatusCodes.isSuccessState(statusCode: httpResponse.statusCode)) {
                do {
                    let result: T = try JSONDecoder().decode(T.self, from: data!)
                    success(result)
                }
                catch {
                    print("Could not parse JSON response: \(error)")
                    failure?(data, response, error)
                }
            }
            else {
                failure?(data, response, error)
            }
        }
        
        task.resume()
        
        // Tell the session to close down, and free all associated objects, once the data-task is completed.
        session.finishTasksAndInvalidate()
    }
}

public struct QPRequestError : Codable {
    public let message: String
    public let errors: Dictionary<String, Array<String>>
    public let error_code: String
}

/*
 else if (QuickPayHttpStatusCodes(rawValue: httpResponse.statusCode) == QuickPayHttpStatusCodes.badRequest) {
 // On bad requests, QuickPay has their own error format, we parse it and return to ease the use
 if let data = data, let qpRequstError = try? JSONDecoder().decode(QPRequestError.self, from: data) {
 self.errorDelegate?.onError(request: self, qpError: qpRequstError)
 return
 }
 }
 */
