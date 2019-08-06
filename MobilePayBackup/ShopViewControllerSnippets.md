@IBAction func handlePayment(_ sender: Any) {
    guard !basketEmpty() else {
        displayOkAlert(title: "Basket is empty", message: "Your basket is empty. Please add some items before paying.")
        return
    }

    if let paymentOption = paymentView.getSelectedPaymentOption() {
        switch paymentOption {
        case .mobilepay:
            if !QuickPay.isMobilePayAvailableOnDevice() {
                displayOkAlert(title: "MobilePay Error", message: "MobilePay is not installed on this device.")
            }
            else {
                handleMobilePay()
            }
            break

        case .paymentcard:
            handlePaymentWindow()
            break

        case .applepay:
            handleApplePay()
            break
        }
    }
}



// MARK: - MobilePay
/**
 Example code to demonstrate the use of MobilePay

 The steps needed to use MobilePay is
 1) Create a payment
 2) Create a payment session
 3) Authorize the payment through MobilePay
 4) Validate that the authoprization went well
 */
extension ShopViewController {

    func handleMobilePay() {
        // Show a progress indicator
        showSpinner(onView: self.view)

        // Step 1) Create a payment
        QPCreatePaymentRequest(parameters: createPaymentParametersFromBasket()).sendRequest(success: { (payment) in

            // Step 2) Create a payment session
            // You need to specify a return url that MobilePay can query to get back to your app
            let mpp = MobilePayParameters(returnUrl: "quickpayexampleshop://", language: "dk", shopLogoUrl: "https://quickpay.net/images/payment-methods/payment-methods.png")
            let createSessionRequestParameters = QPCreatePaymentSessionParameters(amount: Int(self.totalBasketValue() * 100), mobilePay: mpp)
            QPCreatePaymentSessionRequest(id: payment.id, parameters: createSessionRequestParameters).sendRequest(success: { (payment) in

                // Step 3) Authorize the payment through MobilePay
                // This step will query the MobilePay app and the completion handler will be invoked when your app is opened up again
                QuickPay.authorizeWithMobilePay(payment: payment, completion: { (payment) in

                    // Step 4) Validate that the authoprization went well
                    QPGetPaymentRequest(id: payment.id).sendRequest(success: { (payment) in
                        self.removeSpinner()

                        if payment.accepted {
                            self.displayOkAlert(title: "Payment Accepted", message: "The payment was accepted and the acquirer is \(payment.acquirer ?? "unknown")")
                            // Congratulations, you have successfully authorized the payment.
                            // You can now capture the payment when you have shipped the items.
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
