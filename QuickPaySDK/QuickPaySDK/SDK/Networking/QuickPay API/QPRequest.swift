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
        // Logging
        // -------
        if let requestUrl = request.url {
            QuickPay.logger?.log("Requesting URL: \(requestUrl)")
        }
        else {
            QuickPay.logger?.log("Requesting unknown URL")
        }

        if let headers = request.allHTTPHeaderFields {
            QuickPay.logger?.log("Headers: \(headers)")
        }
        
        if let postBody = request.httpBody, let json = String(data: postBody, encoding: String.Encoding.utf8) {
            QuickPay.logger?.log("Body: \(json)")
        }
        
        QuickPay.logger?.log("\n\n")
        // -------
        
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
                QuickPay.logger?.log("Response is not of type HTTPURLResponse")
                failure?(data, response, error)
                return
            }
            
            // If HTTP Success state we parse the result into the corresponding API Model
            if(QuickPayHttpStatusCodes.isSuccessCode(statusCode: httpResponse.statusCode)) {
                do {
                    let result: T = try JSONDecoder().decode(T.self, from: data!)
                    success(result)
                }
                catch {
                    QuickPay.logger?.log("Could not parse JSON response into type (\(T.self)): \(error)")
                    failure?(data, response, error)
                }
            }
            else {
                QuickPay.logger?.log("HTTP response code is not in the success range (200-299(: \(httpResponse.statusCode)")
                failure?(data, response, error)
            }
        }
        
        task.resume()
        
        // Tell the session to close down, and free all associated objects, once the data-task is completed.
        session.finishTasksAndInvalidate()
    }
}

/**
 A model representation of the error json returned by QuickPay in case of an error
 */
public struct QPRequestError : Codable {
    /*
     NOTE: This is not used at the momement, but in the future it will be a part of the request/response cycle
     
     Code snippet:
     if (QuickPayHttpStatusCodes(rawValue: httpResponse.statusCode) == QuickPayHttpStatusCodes.badRequest) {
     // On bad requests, QuickPay has their own error format, we parse it and return to ease the use
     if let data = data, let qpRequstError = try? JSONDecoder().decode(QPRequestError.self, from: data) {
     self.errorDelegate?.onError(request: self, qpError: qpRequstError)
     return
     }
     }
     */
    
    public let message: String
    public let errors: Dictionary<String, Array<String>>
    public let error_code: String
}
