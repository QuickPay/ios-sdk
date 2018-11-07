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
    
    
    // MARK: Business Logic
    
    func sendRequestWithCompletionHandler(completion: (_ success: Bool) -> Void) {
        guard let url = URL(string: "https://api.quickpay.net/payments") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        
        
    }
}

/*
 -(void)sendRequestWithCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
 NSError *error;
 NSData *postData = [NSJSONSerialization dataWithJSONObject:self.parameters.toDictionary options:0 error:&error];
 
 NSURL *url = [NSURL URLWithString:@"https://api.quickpay.net/payments"];
 NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
 
 
 NSString* authString = [self.header encodedAuthorization];
 request.HTTPMethod = @"POST";
 [request setValue:authString forHTTPHeaderField:@"Authorization"];
 [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)postData.length] forHTTPHeaderField:@"Content-Length"];
 [request setValue:self.header.acceptVersion forHTTPHeaderField:@"Accept-Version"];
 [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
 [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
 [request setHTTPBody:postData];
 
 // Create a memory-only session.
 NSURLSessionConfiguration *sessionConffig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
 NSURLSession *ephemeralSession = [NSURLSession sessionWithConfiguration:sessionConffig];
 // Create a new data-task for the session, which queues the HTTP call
 NSURLSessionTask * task = [ephemeralSession dataTaskWithRequest:request completionHandler : completionHandler];
 if(task){
 [task resume];
 }
 // Tell the session to close down, and free all associated objects, once the data-task is completed.
 [ephemeralSession finishTasksAndInvalidate];
 }
*/
