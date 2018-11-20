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

            createLinkRequest.sendRequest(completion: { (paymentLink, data) in
                guard let paymentLink = paymentLink else {
                    self.printToErrorLabel(error: "paymentLink is nil")
                    return
                }
                
                // Step 3: Open the payment URL
                OperationQueue.main.addOperation {
                    QuickPay.openLink(url: paymentLink.url, cancelHandler: {
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
                                let alert = UIAlertController(title: "Payment success", message: "The payment was a success and the acquirer is \(payment.acquirer ?? "Ukendt")", preferredStyle: .alert)
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
        let linkParams = QPGeneratePaymentLinkParameters(id: paymentId, amount: 4200)
        linkParams.payment_methods = "creditcard,mobilepay"
        
        return QPGeneratePaymentLinkRequest(parameters: linkParams)
    }
    
    // Generate a QPCreatePaymentRequest for testing
    private func createPaymentRequest() -> QPCreatePaymentRequest {
        let params = QPCreatePaymentParameters(currency: "DKK", order_id: self.orderIdTextField?.text ?? "0")
        params.text_on_statement = "QuickPay SDK on iOS"
        
        let invoiceAddress = QPAddress()
        invoiceAddress.name = "CV"
        invoiceAddress.city = "Aarhus"
        invoiceAddress.country_code = "DNK"
        params.invoice_address = invoiceAddress
        
        let basket = QPBasket(qty: 1, item_no: "123", item_name: "White Dress", item_price: 42, vat_rate: 0.25)
        params.basket?.append(basket)
        
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
