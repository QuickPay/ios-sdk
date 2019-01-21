//
//  ShowViewController.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 14/01/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import WebKit
import Foundation
import  QuickPaySDK


class ShopViewController: BaseViewController {
    
    // MARK: - Properties
    
    let tshirtPrice = 175.5
    let footballPrice = 425.0
    
    var tshirtsInBasket: Int = 0
    var footballsInBasket: Int = 0
    
    @IBOutlet weak var basketThshirtLabel: UILabel!
    @IBOutlet weak var basketTshirtTotalLabel: UILabel!
    @IBOutlet weak var basketTshirtSection: UIStackView!
    @IBOutlet weak var tshirtStepper: UIStepper!
    
    
    @IBOutlet weak var basketFootballLabel: UILabel!
    @IBOutlet weak var basketFootballTotalLabel: UILabel!
    @IBOutlet weak var basketFootballSection: UIStackView!
    @IBOutlet weak var footballStepper: UIStepper!
    
    @IBOutlet weak var basketTotalLabel: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func tshirtCounterChanged(_ sender: Any) {
        if let stepper = sender as? UIStepper {
            tshirtsInBasket = Int(stepper.value)
            updateBasket()
        }
    }
    
    @IBAction func footballCounterChanged(_ sender: Any) {
        if let stepper = sender as? UIStepper {
            footballsInBasket = Int(stepper.value)
            updateBasket()
        }
    }
    
    @IBAction func payWithCreditCard(_ sender: Any) {
        if validateBasket() {
            doCreditCardPayment()
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        tshirtStepper.value = Double(tshirtsInBasket)
        updateBasket()
    }
    
    
    // MARK: UI
    
    private func updateBasket() {
        // Update the TShirt section
        basketThshirtLabel.text = "T-Shirt  x \(tshirtsInBasket)"
        basketTshirtTotalLabel.text = "\(Double(tshirtsInBasket) * tshirtPrice) DDK"
        
        // Update the football sections
        basketFootballLabel.text = "Football x \(footballsInBasket)"
        basketFootballTotalLabel.text = "\(Double(footballsInBasket) * footballPrice) DDK"
        
        // Update the total section
        basketTotalLabel.text = "\(totalBasketValue()) DDK"
    }
    
    private func totalBasketValue() -> Double {
        return Double(tshirtsInBasket) * tshirtPrice + Double(footballsInBasket) * footballPrice
    }
    
    private func validateBasket() -> Bool {
        if tshirtsInBasket == 0 && footballsInBasket == 0 {
            let alert = UIAlertController(title: "Empty basket", message: "Your basket is empty. Please add some items before paying", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
            return false;
        }
        else {
            return true;
        }
    }
    
    
    // MARK: Util
    
    private func generateRandomOrderId() -> String {
        let randomString = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        return String(randomString.prefix(20))
    }
}

extension ShopViewController: WKNavigationDelegate, QPErrorRequestDelegate {
    func doCreditCardPayment() {
        
        // Step 1: Create a payment
        
        // Create the params needed for creating a payment
        let params = QPCreatePaymentParameters(currency: "DKK", order_id: generateRandomOrderId())
        params.text_on_statement = "QuickPay Example Shop"
        
        let invoiceAddress = QPAddress()
        invoiceAddress.name = "CV"
        invoiceAddress.city = "Aarhus"
        invoiceAddress.country_code = "DNK"
        params.invoice_address = invoiceAddress

        // Fill the basket with the customers cosen items
        let tshirtBasket =   QPBasket(qty: tshirtsInBasket, item_no: "123", item_name: "T-Shirt", item_price: tshirtPrice, vat_rate: 0.25)
        let footballBasket = QPBasket(qty: footballsInBasket, item_no: "321", item_name: "Football", item_price: footballPrice, vat_rate: 0.25)
        params.basket?.append(tshirtBasket)
        params.basket?.append(footballBasket)

        // Create the payment request and set the error delegate
        let createPaymentRequest = QPCreatePaymentRequest(parameters: params)
        createPaymentRequest.errorDelegate = self
        
        createPaymentRequest.sendRequest { (paymentResponse, data) in
            guard let paymentResponse = paymentResponse else {
                print("createPaymentRequest response is nil")
                return
            }
            
            // Step 2: Now that we have the paymentId, we can have QuickPay generate a payment URL for us

            // Create the params needed
            let linkParams = QPGeneratePaymentLinkParameters(id: paymentResponse.id, amount: self.totalBasketValue())
            linkParams.payment_methods = "creditcard,mobilepay"

            let createLinkRequest = QPGeneratePaymentLinkRequest(parameters: linkParams)
            createLinkRequest.errorDelegate = self
            
            createLinkRequest.sendRequest(completion: { (paymentLink, data) in
                guard let paymentLink = paymentLink else {
                    print("paymentLink is nil")
                    return
                }
                
                // Step 3: Open the payment URL
                OperationQueue.main.addOperation {
                    QuickPay.openLink(url: paymentLink.url, cancelHandler: {
                        print("The payment flow was cancelled")
                    }, responseHandler: { (success) in
                        if success == false {
                            print("Payment failed")
                            OperationQueue.main.addOperation {
                                let alert = UIAlertController(title: "Payment failed", message: "The payment failed", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                            return;
                        }
                        
                        // Step 4: We can now request the payment to check the status
                        let getPaymentRequest = QPGetPaymentRequest(id: paymentResponse.id)
                        getPaymentRequest.errorDelegate = self
                        
                        getPaymentRequest.sendRequest(completion: { (payment, data) in
                            guard let payment = payment else {
                                print("payment is nil")
                                return
                            }
                            
                            OperationQueue.main.addOperation {
                                let alert = UIAlertController(title: "Payment success", message: "The payment was a success and the acquirer is \(payment.acquirer ?? "Ukendt")", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                    })
                }
            })
        }
    }
    
    
    // MARK: - QPErrorRequestDelegate Implementation
    
    func onNetworkError(request: QPRequest, data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        else {
            print("Unknown error")
        }
    }
    
    func onError(request: QPRequest, qpError: QPRequestError) {
        print(qpError.message)
    }
}
