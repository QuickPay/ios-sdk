//
//  ShowViewController.swift
//  QuickPayExample
//
//  Created by Steffen Lund Andersen on 14/01/2019.
//  Copyright © 2019 QuickPay. All rights reserved.
//

// Used for Apple Pay
import PassKit
import QuickPaySDK


class ShopViewController: BaseViewController {
    
    // MARK: - Properties
    
    // Basket
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
    
    // Payment
    let applePayPaymentNetworks = [PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
    
    @IBOutlet weak var applePayButtonContainer: UIView!
    
    
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
    
    @IBAction func buySubscription(_ sender: Any) {
        if validateBasket() {
            doBuySubscription()
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        setupApplePayButton()
        
        tshirtStepper.value = Double(tshirtsInBasket)
        updateBasket()
    }
    
    
    // MARK: UI
    
    private func setupApplePayButton() {
        applePayButtonContainer?.backgroundColor = UIColor.clear
        
        var applePayButton = PKPaymentButton(paymentButtonType: .buy, paymentButtonStyle: .black)
        
        if !PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: applePayPaymentNetworks) {
            applePayButton = PKPaymentButton(paymentButtonType: .setUp, paymentButtonStyle: .black)
        }
        applePayButton.translatesAutoresizingMaskIntoConstraints = false
        applePayButton.addTarget(self, action: #selector(doApplePayPayment), for: .touchUpInside)
        
        applePayButtonContainer?.addSubview(applePayButton)
        
        applePayButtonContainer?.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerX, relatedBy: .equal, toItem: applePayButtonContainer, attribute: .centerX, multiplier: 1, constant: 0))
        applePayButtonContainer?.addConstraint(NSLayoutConstraint(item: applePayButton, attribute: .centerY, relatedBy: .equal, toItem: applePayButtonContainer, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
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

// MARK: - Apple Pay Code
extension ShopViewController: PKPaymentAuthorizationViewControllerDelegate {
    @objc func doApplePayPayment() {
        let request = PKPaymentRequest()
        
        // This merchantIdentifier should have been created for you in Xcode when you set up the ApplePay capabilities.
        request.merchantIdentifier = "merchant.com.codebaseivs.quickpayexample"
        request.countryCode = "DK" // Standard ISO country code. The country in which you make the charge.
        request.currencyCode = "DKK" // Standard ISO currency code. Any currency you like.
        request.supportedNetworks = applePayPaymentNetworks
        request.merchantCapabilities = .capability3DS // 3DS or EMV. Check with your payment platform or processor.
        
        // Set the items that you are charging for. The last item is the total amount you want to charge.
        let tshirt =   PKPaymentSummaryItem(label: "T-Shirt  x \(tshirtsInBasket)", amount: NSDecimalNumber(floatLiteral: Double(tshirtsInBasket) * tshirtPrice), type: .final)
        let football = PKPaymentSummaryItem(label: "Football x \(footballsInBasket)", amount: NSDecimalNumber(floatLiteral: Double(footballsInBasket) * footballPrice), type: .final)
        let total =    PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(floatLiteral: totalBasketValue()), type: .final)
        
        request.paymentSummaryItems = [tshirt, football, total]
        
        // Create a PKPaymentAuthorizationViewController from the request
        if let authorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: request) {
            authorizationViewController.delegate = self
            present(authorizationViewController, animated: true, completion: nil)
        }
        else {
            print("Nope not now")
        }
    }
    
    // MARK: PKPaymentAuthorizationViewControllerDelegate Implementation
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
        
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
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

        let createPaymentRequest = QPCreatePaymentRequest(parameters: params)
        
        createPaymentRequest.sendRequest(success: { (qpPayment) in
            let authParams = QPAuthorizePaymentParams(id: qpPayment.id, amount: Int(exactly: self.totalBasketValue() * 100) ?? 1400)
            let card = QPCard()
            card.apple_pay_token = QPApplePayToken(pkPaymentToken: payment.token)
            authParams.card = card
            
            
            let authRequest = QPAuthorizePaymentRequest(parameters: authParams)
            authRequest.sendRequest(success: { (payment) in
                completion(PKPaymentAuthorizationResult.init(status: .success, errors: nil))
            }, failure: { (data, response, error) in
                if let data = data {
                    print(data)
                }
                
                if let error = error {
                    print(error)
                }
                
                if let response = response {
                    print(response)
                }

                completion(PKPaymentAuthorizationResult.init(status: .failure, errors: nil))
            })
            
        }, failure: nil)
        
        
        
        
        
//        STPAPIClient.shared().createToken(with: payment) { (token, error) in
//            if (error != nil) {
//                print(error)
//                completion(PKPaymentAuthorizationResult.init(status: .failure, errors: nil))
//                return
//            }
//
//            // 5
//            let url = URL(string: "http://192.168.0.70:5000/pay")  // Replace with computers local IP Address!
//
//            var request = URLRequest(url: url!)
//            request.httpMethod = "POST"
//            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/json", forHTTPHeaderField: "Accept")
//
//            // 6
//            let body = ["stripeToken": token!.tokenId,
//                        "amount": "42500",
//                        "description": "Cool shop",
//                        "shipping": [
//                            "city": "Aarhus",
//                            "state": "Aarhus",
//                            "zip": "8000",
//                            "firstName": "Johnny",
//                            "lastName": "Hansen"]
//                ] as [String : Any]
//
//            var error: NSError?
//            request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions())
//
//            // 7
//            NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) { (response, data, error) -> Void in
//                if (error != nil) {
//                    completion(PKPaymentAuthorizationResult.init(status: .failure, errors: nil))
//                } else {
//                    completion(PKPaymentAuthorizationResult.init(status: .success, errors: nil))
//                }
//            }
//        }
    }
    
    //    struct Address {
    //        var Street: String?
    //        var City: String?
    //        var State: String?
    //        var Zip: String?
    //        var FirstName: String?
    //        var LastName: String?
    //
    //        init() {
    //        }
    //    }
    //
    //
    //    func createShippingAddressFromRef(address: ABRecord!) -> Address {
    //        var shippingAddress: Address = Address()
    //
    //        shippingAddress.FirstName = ABRecordCopyValue(address, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
    //        shippingAddress.LastName = ABRecordCopyValue(address, kABPersonLastNameProperty)?.takeRetainedValue() as? String
    //
    //        let addressProperty : ABMultiValueRef = ABRecordCopyValue(address, kABPersonAddressProperty).takeUnretainedValue() as ABMultiValueRef
    //        if let dict : NSDictionary = ABMultiValueCopyValueAtIndex(addressProperty, 0).takeUnretainedValue() as? NSDictionary {
    //            shippingAddress.Street = dict[String(kABPersonAddressStreetKey)] as? String
    //            shippingAddress.City = dict[String(kABPersonAddressCityKey)] as? String
    //            shippingAddress.State = dict[String(kABPersonAddressStateKey)] as? String
    //            shippingAddress.Zip = dict[String(kABPersonAddressZIPKey)] as? String
    //        }
    //
    //        return shippingAddress
    //    }
    
    
    //    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void) {
    //
    //    }
    //
    //    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
    //
    //    }
    //
    //    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
    //
    //    }
}


// MARK: - Subscription Code
extension ShopViewController {
    func doBuySubscription() {
        // Step 1: Create Subscription
        
        // Create the params needed for creating a subscription
        let params = QPCreateSubscriptionParameters(currency: "DKK", order_id: generateRandomOrderId(), description: "QuickPay Example Shop Subscription")
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
        
        // Create the subscription request and set the error delegate
        QPCreateSubscriptionRequest(parameters: params).sendRequest(success: { (subscription) in
            // Step 2: Generate URL
            QPCreateSubscriptionLinkRequest(parameters: QPCreateSubscriptionLinkParameters(id: subscription.id, amount: 30000)).sendRequest(success: { (subscriptionLink) in
                // Step 3: Open the URL and authorize the payment
                QuickPay.openLink(subscriptionLink: subscriptionLink, cancelHandler: {
                    // CANCEL
                }, responseHandler: { (success) in
                    // WEE
                })
            }, failure: self.handleQuickPayNetworkErrors)
        }, failure: self.handleQuickPayNetworkErrors)
    }
    
    internal func handleQuickPayNetworkErrors(data: Data?, response: URLResponse?, error: Error?) {
        OperationQueue.main.addOperation {
            let message = error != nil ? error!.localizedDescription : "Unknown error"
            let alert = UIAlertController(title: "Request failed", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - Credit Card Code
extension ShopViewController {
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
        QPCreatePaymentRequest(parameters: params).sendRequest(success: { (payment) in
            // Step 2: Now that we have the paymentId, we can have QuickPay generate a payment URL for us
            
            // Create the params needed
            let linkParams = QPCreatePaymentLinkParameters(id: payment.id, amount: self.totalBasketValue() * 100.0)
//            linkParams.payment_methods = "creditcard,mobilepay,applepay"
            
            QPCreatePaymentLinkRequest(parameters: linkParams).sendRequest(success: { (paymentLink) in
                // Step 3: Open the payment URL
                QuickPay.openLink(paymentLink: paymentLink, cancelHandler: {
                    self.displayOkAlert(title: "Payment Cancelled", message: "The payment flow was cancelled")
                }, responseHandler: { (success) in
                    if success == false {
                        self.displayOkAlert(title: "Payment Failed", message: "The payment failed")
                        return
                    }

                    // Step 4: We can now request the payment to check the status
                    QPGetPaymentRequest(id: payment.id).sendRequest(success: { (payment) in
                        if payment.accepted {
                            self.displayOkAlert(title: "Payment Accepted", message: "The payment was a success and the acquirer is \(payment.acquirer ?? "Ukendt")")
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

extension ShopViewController {
    
    func displayOkAlert(title: String, message: String) {
        OperationQueue.main.addOperation {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
