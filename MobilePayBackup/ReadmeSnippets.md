### MobilePay Online

QuickPay SDK supports MobilePay natively so you can create a great app experience. To query the MobilePay App you need to make some changes to your project settings and implement the payment as shown later in this guide.

It is recommended that you check if the users have the MobilePay App installed and only show the payment option if it is available. The QuickPay class can help you with this.

```swift
QuickPay.isMobilePayAvailable()
```


#### URL Schemes for MobilePay Online

To query the MobilePay App you need to whitelist the `mobilepayonline` URL scheme to the `LSApplicationQueriesSchemes` array in your `Info.plist`. With this done your application can now query the MobilePay App with the needed information for MobilePay to handle the authorization of a payment.

You also need to specify a custom URL scheme for the MobilePay App to query back to when it is done doing its job. This is done in the `URL types` array in your `Info.plist`.

You can read more about the URL schemes on [https://developers.apple.com](https://developer.apple.com/documentation/uikit/core_app/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)


#### Payment flow for MobilePay Online

First, you need to create a payment just like with the payment window, but after that, the flow is different since we do not have the payment window to handle a lot of tasks for us.

When you have created your payment you need to start a MobilePay payment session. Create a `MobilePayParameters` object and specify the custom URL scheme that you created earlier. You can also specify the language of MobilePay and add a URL to a logo you want it to be displayed. Add this information to a `QPCreatePaymenSessionParameters` along with the amount of money you want to authorize. Finally, put everything together in a `QPCreatePaymenSessionRequest` and send the request.

```swift
let mobilePayParameters = MobilePayParameters(returnUrl: "quickpayexampleshop://", language: "dk", shopLogoUrl: "https://SomeUrl/SomeImage.png")
let sessionParameters = QPCreatePaymenSessionParameters(amount: 100, mobilePay: mpp)

let request = QPCreatePaymenSessionRequest(id: payment.id, parameters: sessionParameters)

request.sendRequest(success: { (payment) in
    // Handle the payment
}, failure: { (data, response, error) in
    // Handle the failure
})
```

With the payment containing a session id, we can now query MobilePay to authorize the payment.

```swift
QuickPay.authorizeWithMobilePay(payment: payment, completion: { (payment) in {
    // Handle the payment
}, failure: {
    // Handle the failure
}
```

In the completion handler, we need to check the status of the payment. This is done in the same way as with the payment window. Create a `QPGetPaymentRequest` with the payment id and check if the updated payment is accepted.
