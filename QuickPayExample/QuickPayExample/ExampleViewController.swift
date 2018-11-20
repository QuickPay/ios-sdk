//
//  ViewController.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 06/11/2018.
//  Copyright © 2018 QuickPay. All rights reserved.
//

import UIKit
import WebKit
import QuickPaySDK

class ExampleViewController: BaseViewController, WKNavigationDelegate {

    // MARK: Outlets
    
    @IBOutlet var orderIdTextField:  UITextField?
    @IBOutlet var errorMessageLabel: UILabel?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMessageLabel?.text = ""
    }
    
    
    // MARK: - IBActions
    
    @IBAction func doPayment(_ sender: Any) {
        // Clear the message label
        self.printToErrorLabel(error: "")
        
        // Step 1: Create a payment
        let createPaymentRequest = self.createPaymentRequest()
        createPaymentRequest.errorDelegate = self
        
        createPaymentRequest.sendRequest { (paymentResponse, data) in
            guard let paymentResponse = paymentResponse else {
                self.printToErrorLabel(error: "createPaymentRequest response is nil")
                return
            }

            // Step 2: Now that we have the paymentId, we can have QuickPay generate a payment URL for us
            let createLinkRequest = self.createLinkRequest(paymentId: paymentResponse.id)
            createLinkRequest.errorDelegate = self

            createLinkRequest.sendRequest(completion: { (linkResponse, data) in
                guard let linkResponse = linkResponse else {
                    self.printToErrorLabel(error: "linkResponse is nil")
                    return
                }
                
                // Step 3: Open the payment URL
                OperationQueue.main.addOperation {
                    QuickPay.openLink(url: linkResponse.url, cancelHandler: {
                        self.printToErrorLabel(error: "The payment flow was cancelled")
                    }, responseHandler: { (success) in
                        if success == false {
                            self.printToErrorLabel(error: "Payment failed")
                            OperationQueue.main.addOperation {
                                let alert = UIAlertController(title: "Payment failed", message: "The payment failed", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            return;
                        }

                        // Step 4: We can now request the payment to check the status
                        let getPaymentRequest = self.creategetPaymentRequest(paymentId: paymentResponse.id)
                        getPaymentRequest.errorDelegate = self
                        
                        getPaymentRequest.sendRequest(completion: { (payment, data) in
                            guard let payment = payment else {
                                self.printToErrorLabel(error: "payment is nil")
                                return
                            }
                            
                            OperationQueue.main.addOperation {
                                let alert = UIAlertController(title: "Payment success", message: "The payment was a success and the acquirer is \(payment.acquirer)", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                    })
                }
            })
        }
    }
    
    
    // MARK: - Helpers
    
    private func creategetPaymentRequest(paymentId: Int) -> QPGetPaymentRequest {
        return QPGetPaymentRequest(id: paymentId)
    }
    
    // Generate a QPGeneratePaymentLinkRequest for testing
    private func createLinkRequest(paymentId: Int) -> QPGeneratePaymentLinkRequest {
        let linkParams = QPGeneratePaymentLinkParameters()
        linkParams.id = paymentId
        linkParams.amount = 4200
        linkParams.paymentMethods = "creditcard,mobilepay"
        
        return QPGeneratePaymentLinkRequest(parameters: linkParams)
    }
    
    // Generate a QPCreatePaymentRequest for testing
    private func createPaymentRequest() -> QPCreatePaymentRequest {
        // The orderId and currency parameters are required.
        let params = QPCreatePaymentParameters()
        params.orderId = self.orderIdTextField?.text ?? "0" // Remember to increment the orderId since the values needs to be unique
        params.currency = "DKK"
        params.textOnStatement = "QuickPay SDK on iOS"
        
        params.invoiceAddress = QPAddress()
        params.invoiceAddress?.name = "CV"
        params.invoiceAddress?.city = "Aarhus"
        params.invoiceAddress?.countryCode = "DNK"
        
        let basket1 = QPBasket()
        basket1.itemName = "White Dress"
        basket1.itemNo = "123"
        basket1.itemPrice = 42
        basket1.qty = 1
        basket1.vatRate = 0.25
        params.basket?.append(basket1)
        
        return QPCreatePaymentRequest(parameters: params)
    }
    
    private func printToErrorLabel(error: String) {
        let doPrint = {
            self.errorMessageLabel?.text = error
        }
        
        if Thread.isMainThread {
            doPrint()
        }
        else {
            OperationQueue.main.addOperation {
                doPrint()
            }
        }
    }
}

extension ExampleViewController : QPErrorRequestDelegate {
    func onNetworkError(request: QPRequest, data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            printToErrorLabel(error: error.localizedDescription)
        }
        else {
            printToErrorLabel(error: "Unknown error")
        }
    }
    
    func onError(request: QPRequest, qpError: QPRequestError) {
        printToErrorLabel(error: qpError.message)
    }
}
