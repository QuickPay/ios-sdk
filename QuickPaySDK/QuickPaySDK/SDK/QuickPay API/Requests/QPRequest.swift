//
//  QPRequest.swift
//  QuickPaySDK
//
//  Created by Steffen Lund Andersen on 16/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import Foundation

/**
 Used for retrieving errors from QPRequest
 */
public protocol QPErrorRequestDelegate {
    /// Respons to network errors
    func onNetworkError(request: QPRequest, data: Data?, response: URLResponse?, error: Error?)

    /// On 400 (Bad Request), get the QPRequestError that explains the error
    func onError(request: QPRequest, qpError: QPRequestError)
}

public class QPRequest {
    
    // MARK: - Properties
    
    public let quickPayAPIBaseUrl = "https://api.quickpay.net"
    internal let headers = QPHeaders()
    
    
    // MARK: Delegates
    
    public var errorDelegate: QPErrorRequestDelegate?
    
    
    // MARK: - URL Request
    
    func sendRequest(request: URLRequest, completion: @escaping (_ data: Data?) -> Void) {
        // Create a memory-only session.
        let config = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: config)
        
        // Create a new data-task for the session, which queues the HTTP call
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                self.errorDelegate?.onNetworkError(request: self, data: data, response: response, error: error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                self.errorDelegate?.onNetworkError(request: self, data: data, response: response, error: error)
                return
            }
            
            if(HTTPStatusSuccessRange.contains(httpResponse.statusCode)) {
                // SUCCESS
                completion(data)
            }
            else if (httpResponse.statusCode == HTTPStatusCode.badRequest.rawValue) {
                // On bad requests, QuickPay has their own error format, we parse it and return to ease the use
                if let data = data, let qpRequstError = try? JSONDecoder().decode(QPRequestError.self, from: data) {
                    self.errorDelegate?.onError(request: self, qpError: qpRequstError)
                    return
                }
            }
            else {
                self.errorDelegate?.onNetworkError(request: self, data: data, response: response, error: error)
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
