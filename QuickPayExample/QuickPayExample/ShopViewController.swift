//
//  ShowViewController.swift
//  QuickPayExample
//
//  Created on 14/01/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import QuickPaySDK

class ShopViewController: UIViewController {
    
    // MARK: - Properties
    
    // Basket
    let tshirtPrice = 0.5
    let footballPrice = 1.0
    
    var tshirtCount = 0
    var footballCount = 0
    
    @IBOutlet weak var basketThshirtLabel: UILabel!
    @IBOutlet weak var basketTshirtTotalLabel: UILabel!
    @IBOutlet weak var basketTshirtSection: UIStackView!
    
    @IBOutlet weak var basketFootballLabel: UILabel!
    @IBOutlet weak var basketFootballTotalLabel: UILabel!
    @IBOutlet weak var basketFootballSection: UIStackView!
    
    @IBOutlet weak var basketTotalLabel: UILabel!
    
    @IBOutlet weak var creditCardView: SelectableView!
    @IBOutlet weak var mobilePayView: SelectableView!
    
    @IBOutlet weak var paymentButton: UIButton!
    
    
    // MARK: - IBActions
    
    @IBAction func tshirtCountChanged(_ sender: UIStepper) {
        tshirtCount = Int(sender.value)
        updateBasket()
    }
    
    @IBAction func footballCountChanged(_ sender: UIStepper) {
        footballCount = Int(sender.value)
        updateBasket()
    }

    @IBAction func handlePayment(_ sender: Any) {
        guard !basketEmpty() else {
            displayOkAlert(title: "Basket is empty", message: "Your basket is empty. Please add some items before paying.")
            return
        }
        
        if creditCardView.isSelected {
            handleCreditCardPayment()
        }
        else if mobilePayView.isSelected {
            if !QuickPay.mobilePayAvailable() {
                displayOkAlert(title: "MobilePay Error", message: "MobilePay is not installed on this device.")
            }
            else {
                handleMobilePayPayment()
            }
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarImage = UIImageView(image: UIImage(named: "Logo Inverse"))
        navigationBarImage.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationBarImage

        paymentButton.isEnabled = false
        creditCardView.selectionDelegate = self
        mobilePayView.selectionDelegate = self
        
        updateBasket()
    }
    

    // MARK: - UI
    
    private func updateBasket() {
        // Update the TShirt section
        basketThshirtLabel.text = "T-Shirt  x \(tshirtCount)"
        basketTshirtTotalLabel.text = "\(Double(tshirtCount) * tshirtPrice) DDK"
        
        // Update the football sections
        basketFootballLabel.text = "Football x \(footballCount)"
        basketFootballTotalLabel.text = "\(Double(footballCount) * footballPrice) DDK"
        
        // Update the total section
        basketTotalLabel.text = "\(totalBasketValue()) DDK"
    }
    
    private func totalBasketValue() -> Double {
        return Double(tshirtCount) * tshirtPrice + Double(footballCount) * footballPrice
    }
    
    private func basketEmpty() -> Bool {
        if tshirtCount == 0 && footballCount == 0 {
            return true;
        }
        else {
            return false;
        }
    }
    
    
    // MARK: - Utils
    
    private func createPaymentParametersFromBasket() -> QPCreatePaymentParameters {
        // Create the params needed for creating a payment
        let params = QPCreatePaymentParameters(currency: "DKK", order_id: String.randomString(len: 20))
        params.text_on_statement = "QuickPay Example Shop"
        
        let invoiceAddress = QPAddress()
        invoiceAddress.name = "Some Street"
        invoiceAddress.city = "Aarhus"
        invoiceAddress.country_code = "DNK"
        params.invoice_address = invoiceAddress
        
        // Fill the basket with the tshirts and footballs
        let tshirtBasket =   QPBasket(qty: tshirtCount, item_no: "1", item_name: "T-Shirt", item_price: tshirtPrice, vat_rate: 0.25)
        let footballBasket = QPBasket(qty: footballCount, item_no: "2", item_name: "Football", item_price: footballPrice, vat_rate: 0.25)
        params.basket?.append(tshirtBasket)
        params.basket?.append(footballBasket)

        return params
    }
}

// MARK: - MobilePay
extension ShopViewController {

    func handleMobilePayPayment() {
        // Fire up a progress indicator
        showSpinner(onView: self.view)
        
        // Step 1: Create a payment
        QPCreatePaymentRequest(parameters: createPaymentParametersFromBasket()).sendRequest(success: { (payment) in

            // Step 2: Create a payment session with a return URL
            let mpp = MobilePayParameters(returnUrl: "quickpayexampleshop://", language: "dk", shopLogoUrl: "https://quickpay.net/images/payment-methods/payment-methods.png")
            let createSessionRequestParameters = CreatePaymenSessionParameters(amount: Int(self.totalBasketValue() * 100), mobilePay: mpp)
            QPCreatePaymenSessionRequest(id: payment.id, parameters: createSessionRequestParameters).sendRequest(success: { (payment) in
                
                // Step 3: Authorize through MobilePay
                QuickPay.authorizeWithMobilePay(payment: payment, completion: { (payment) in
                    
                    // Step 4: Request the payment to get the status
                    QPGetPaymentRequest(id: payment.id).sendRequest(success: { (payment) in
                        self.removeSpinner()

                        if payment.accepted {
                            self.displayOkAlert(title: "Payment Accepted", message: "The payment was accepted and the acquirer is \(payment.acquirer ?? "unknown")")
                        }
                        else {
                            self.displayOkAlert(title: "Payment Not Accepted", message: "The payment was not accepted")
                        }
                    }, failure: self.handleQuickPayNetworkErrors)
                }, failure: {
                    self.displayOkAlert(title: "MobilePay Failed", message: "Could not authorize with MobilePay")
                })

            }, failure: self.handleQuickPayNetworkErrors)
        }, failure: self.handleQuickPayNetworkErrors)
    }
}


// MARK: - Payment Window
extension ShopViewController {
    
    func handleCreditCardPayment() {
        showSpinner(onView: self.view)

        // Step 1: Create a payment
        QPCreatePaymentRequest(parameters: createPaymentParametersFromBasket()).sendRequest(success: { (payment) in
            // Step 2: Create the payment URL
            let linkParams = QPCreatePaymentLinkParameters(id: payment.id, amount: self.totalBasketValue() * 100.0)
            
            QPCreatePaymentLinkRequest(parameters: linkParams).sendRequest(success: { (paymentLink) in
                // Step 3: Open the payment URL
                QuickPay.openLink(paymentLink: paymentLink, onCancel: {
                    self.removeSpinner()
                    self.displayOkAlert(title: "Payment Cancelled", message: "The payment was cancelled")
                }, onResponse: { (success) in
                    if success == false {
                        self.removeSpinner()
                        self.displayOkAlert(title: "Payment Failed", message: "The payment failed")
                        return
                    }
                    
                    // Step 4: Request the payment to get the status
                    QPGetPaymentRequest(id: payment.id).sendRequest(success: { (payment) in
                        self.removeSpinner()
                        if payment.accepted {
                            self.displayOkAlert(title: "Payment Accepted", message: "The payment was accepted and the acquirer is \(payment.acquirer ?? "unknown")")
                        }
                        else {
                            self.displayOkAlert(title: "Payment Not Accepted", message: "The payment was not accepted")
                        }
                    }, failure: self.handleQuickPayNetworkErrors)
                })
            }, failure: self.handleQuickPayNetworkErrors)
        }, failure: self.handleQuickPayNetworkErrors)
    }
    
}

extension ShopViewController: SelectionDelegate {
    
    func selectionChanged(selectableView: SelectableView) {
        if selectableView.isSelected {
            if selectableView != mobilePayView {
                mobilePayView.isSelected = false
            }
            
            if selectableView != creditCardView {
                creditCardView.isSelected = false
            }
        }
        
        paymentButton.isEnabled = creditCardView.isSelected || mobilePayView.isSelected
    }
    
}

extension ShopViewController {
    
    internal func handleQuickPayNetworkErrors(data: Data?, response: URLResponse?, error: Error?) {
        if let data = data {
            print(String(data: data, encoding: String.Encoding.utf8)!)
        }
        
        if let error = error {
            print(error)
        }
        
        if let response = response {
            print(response)
        }
        
        displayOkAlert(title: "Request failed", message: error?.localizedDescription ?? "Unknown error")
    }
    
    internal func displayOkAlert(title: String, message: String) {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
