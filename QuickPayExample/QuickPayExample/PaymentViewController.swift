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
import PassKit

class ExampleViewController: BaseViewController, WKNavigationDelegate {

    // MARK: Outlets
    
    @IBOutlet weak var orderIdTextField:  UITextField?
    @IBOutlet weak var errorMessageLabel: UILabel?
    @IBOutlet weak var applePayContainer: UIView?
    
    
    // MARK: Properties
    
    let paymentNetworks = [PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
    
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        generateOrderId(self)
        
        errorMessageLabel?.text = ""
        
        applePayContainer?.backgroundColor = UIColor.clear

        
        var applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: paymentNetworks) {
            applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
        }
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.addTarget(self, action: #selector(doApplePayPayment), for: .touchUpInside)

        applePayContainer?.addSubview(applePayButton)
        
        applePayContainer?.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerX, relatedBy: .equal, toItem: applePayContainer, attribute: .centerX, multiplier: 1, constant: 0))
        applePayContainer?.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerY, relatedBy: .equal, toItem: applePayContainer, attribute: .centerY, multiplier: 1, constant: 0))
    }

    
    // MARK: Actions
    
    @objc func doApplePayPayment() {
        let request = PKPaymentRequest()
        
        // This merchantIdentifier should have been created for you in Xcode when you set up the ApplePay capabilities.
        request.merchantIdentifier = "merchant.com.codebaseivs.quickpayexample"
        request.countryCode = "DK" // Standard ISO country code. The country in which you make the charge.
        request.currencyCode = "DKK" // Standard ISO currency code. Any currency you like.
        request.supportedNetworks = paymentNetworks
        request.merchantCapabilities = .capability3DS // 3DS or EMV. Check with your payment platform or processor.
        
        // Set the items that you are charging for. The last item is the total amount you want to charge.
        let shinobiToySummaryItem = PKPaymentSummaryItem(label: "Shinobi Cuddly Toy", amount: NSDecimalNumber(floatLiteral: 22.99), type: .final)
        let shinobiPostageSummaryItem = PKPaymentSummaryItem(label: "Postage", amount: NSDecimalNumber(floatLiteral: 3.99), type: .final)
        let shinobiTaxSummaryItem = PKPaymentSummaryItem(label: "Tax", amount: NSDecimalNumber(floatLiteral: 2.29), type: .final)
        let total = PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(floatLiteral: 29.27), type: .final)
        
        request.paymentSummaryItems = [shinobiToySummaryItem, shinobiPostageSummaryItem, shinobiTaxSummaryItem, total]
        
        // Create a PKPaymentAuthorizationViewController from the request
        if let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request) {
            authorizationViewController.delegate = self
            present(authorizationViewController, animated: true, completion: nil)
        }
        else {
            print("Nope not now")
        }
    }
    
    
    // MARK: - IBActions
    
    @IBAction func generateOrderId(_ sender: Any) {
        let randomString = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        orderIdTextField?.text = String(randomString.prefix(20))
    }
    
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
//        linkParams.payment_methods = "creditcard,mobilepay,applepay"
        
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

extension ExampleViewController : PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        print("you need to do stuff")
    }
}
