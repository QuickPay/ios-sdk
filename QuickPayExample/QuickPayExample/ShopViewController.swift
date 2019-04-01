//
//  ShowViewController.swift
//  QuickPayExample
//
//  Created on 14/01/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

import QuickPaySDK
import PassKit

class ShopViewController: UIViewController {
    
    // MARK: - Properties
        var appleId: Int?
    
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
    
    @IBOutlet weak var paymentButton: UIButton!
    @IBOutlet weak var paymentView: PaymentView!
    
    
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
        
        if let paymentOption = paymentView.getSelectedPaymentOption() {
            switch paymentOption {
            case .mobilePay:
                if !QuickPay.isMobilePayAvailable() {
                    displayOkAlert(title: "MobilePay Error", message: "MobilePay is not installed on this device.")
                }
                else {
                    handleMobilePayPayment()
                }
                break

            case .creditCard:
                handleCreditCardPayment()
                break
                
            case .applePay:
                handleApplePayPayment()
                break
            }
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarImage = UIImageView(image: UIImage(named: "Logo Inverse"))
        navigationBarImage.contentMode = .scaleAspectFit
        navigationItem.titleView = navigationBarImage

        paymentView.delegate = self
        paymentButton.isEnabled = false
        
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
    
    internal func createPaymentParametersFromBasket() -> QPCreatePaymentParameters {
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

// MARK: - Apple Pay
extension ShopViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    func handleApplePayPayment() {
        if !PKPaymentAuthorizationViewController.canMakePayments() {
            PKPassLibrary().openPaymentSetup()
            return;
        }

        let request = PKPaymentRequest()

        // This merchantIdentifier should have been created for you in Xcode when you set up the ApplePay capabilities.
        request.merchantIdentifier = "merchant.quickpayexample"
        request.countryCode = "DK" // Standard ISO country code. The country in which you make the charge.
        request.currencyCode = "DKK" // Standard ISO currency code. Any currency you like.
        request.supportedNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.JCB]
        request.merchantCapabilities = .capability3DS // 3DS or EMV. Check with your payment platform or processor.
        
        
        request.paymentSummaryItems = []
        
        if tshirtCount > 0 {
            request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "\(tshirtCount) T-Shirts", amount: NSDecimalNumber(floatLiteral: Double(tshirtCount)*tshirtPrice)))
        }
        
        if footballCount > 0 {
            request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "\(footballCount) Footballs", amount: NSDecimalNumber(floatLiteral: Double(footballCount)*footballPrice)))
        }

        request.paymentSummaryItems.append(PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(floatLiteral: totalBasketValue())))
        
        if let viewController = PKPaymentAuthorizationViewController(paymentRequest: request) {
            viewController.delegate = self
            self.present(viewController, animated: true, completion: nil)
        }
        else {
            print("STUFF WENT SOUTH")
        }
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        // Create the params needed for creating a payment
        let params = QPCreatePaymentParameters(currency: "DKK", order_id: String.randomString(len: 20))
        params.text_on_statement = "QuickPay Example Shop"
        
        let invoiceAddress = QPAddress()
        invoiceAddress.name = "CV"
        invoiceAddress.city = "Aarhus"
        invoiceAddress.country_code = "DNK"
        params.invoice_address = invoiceAddress
        
        // Fill the basket with the customers cosen items
        let tshirtBasket =   QPBasket(qty: tshirtCount, item_no: "123", item_name: "T-Shirt", item_price: tshirtPrice, vat_rate: 0.25)
        let footballBasket = QPBasket(qty: footballCount, item_no: "321", item_name: "Football", item_price: footballPrice, vat_rate: 0.25)
        params.basket?.append(tshirtBasket)
        params.basket?.append(footballBasket)
        
        let createPaymentRequest = QPCreatePaymentRequest(parameters: params)

        createPaymentRequest.sendRequest(success: { (qpPayment) in
            print("PAYMENT ID: \(qpPayment.id)")
            self.appleId = qpPayment.id
            
            let authParams = QPAuthorizePaymentParams(id: qpPayment.id, amount: Int(self.totalBasketValue() * 100))
            let card = QPCard()
            card.apple_pay_token = QPApplePayToken(pkPaymentToken: payment.token)
            authParams.card = card
            
            let authRequest = QPAuthorizePaymentRequest(parameters: authParams)
            
            authRequest.sendRequest(success: { (qpPayment) in
                completion(PKPaymentAuthorizationResult.init(status: .success, errors: nil))
            }, failure: { (data, response, error) in
                self.handleQuickPayNetworkErrors(data: data, response: response, error: error)
                completion(PKPaymentAuthorizationResult.init(status: .failure, errors: nil))
            })
        }) { (data, response, error) in
            self.handleQuickPayNetworkErrors(data: data, response: response, error: error)
            completion(PKPaymentAuthorizationResult.init(status: .failure, errors: nil))
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        if let paymentId = appleId {
            self.appleId = nil
            
            QPGetPaymentRequest(id: paymentId).sendRequest(success: { (qpPayment) in
                self.dismiss(animated: true, completion: nil)

                if qpPayment.accepted {
                    self.displayOkAlert(title: "Payment Accepted", message: "The payment was accepted and the acquirer is \(qpPayment.acquirer ?? "unknown")")
                }
                else {
                    self.displayOkAlert(title: "Payment Not Accepted", message: "The payment was not accepted")
                }
            }) { (data, response, error) in
                self.dismiss(animated: true, completion: nil)
            }
        }
        else {
            self.dismiss(animated: true, completion: nil)
            self.displayOkAlert(title: "Payment Not Accepted", message: "The payment was not accepted")
        }
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

extension ShopViewController: PaymentViewDelegate {
    
    func titleForPaymentMethod(_ paymentView: PaymentView, paymentMethod: PaymentView.PaymentMethod) -> String? {
        return nil
    }
    
    func didSelectPaymentMethod(_ paymentView: PaymentView, paymentMethod: PaymentView.PaymentMethod) {
        paymentButton.isEnabled = true
    }
    
}
