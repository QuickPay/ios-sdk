# QuickPay SDK

QuickPay SDK wraps the [QuickPay API](https://learn.quickpay.net/tech-talk/api/services/#services "QuickPay API") and provides the necessary functionality to add native payments to your app.


## Usage
This guide will take you through the steps needed to integrate the QuickPay SDK with your code.


### Initialization
In your AppDelegate you need to initialize the SDK with your API key.   
```swift
QuickPay.initWith(apiKey: String)
```


TODO: Querying URL Schemes with canOpenURL

If you want to use any of the payment methods that requires opening another app (MobilePay, Swish, etc.) you need to let the SDK know when your app is being opened again. To do so add this function to your AppDelegate.
```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    QuickPay.application(open: url, options: options)
    return true
}
```

### Debugging

The QuickPay SDK supports a simple log delegate that forwards som debugging info which can be very helpful during the development process. This debug info is not stored anywhere by the SDK since log handling is the responsibility of the application developers.

To use this mechanism you must conform to the `LogDelegate` protocol and pass it to the QuickPay class.

If you just want the debug info being outputted to the XCode console, the SDK comes bundled with a very simple Logger that uses the 'print' function to output. To use this simple PrintLogger add the following snippet to your AppDelegate.

```swift
QuickPay.logDelegate = PrintLogger()
```


### Payment flow

To make a payment and authorize it you need to follow these four steps
1. Create a payment
2. Create a payment session
3. Authorize the payment
4. Check the payment status to see if the authorization went well

All payments needs to go through these four steps but some services, like the payment window, will handle multiple of these steps in one action.


### Payment Window

The payment windows is the easiest and quickest way to get payments up and running, it is also the only way you can accept payments with credit cards through the QuickPay SDK. App based payment options like MobilePay and Apple Pay are also available through the payment window. The payment window handles step 2 and 3 of the payment flow for you so instead you need to display the payment window to the user.

1. Create payment
2. Generate a payment url and display the payment window
3. Check the payment status

To create a payment you first to specify some parameters which are wrapped in the `QPCreatePaymentParameters` class. Afterwards you pass the parameters to the constructor of a `QPCreatePaymentRequest`. Last you need to send the request to QuickPay, this is done with `sendRequest` function on the request itself which requires a success and failure handler.

```swift
let params = QPCreatePaymentParameters(currency: "DKK", order_id: "SomeOrderId")
let request = QPCreatePaymentRequest(parameters: params)

request.sendRequest(success: { (payment) in
    // Handle the payment
}, failure: { (data, response, error) in
    // Handle the failure
})
```

### MobilePay

QuickPay supports MobilePay on iOS either through the web based payment window or by natively querying the MobilePay App. To enable MobilePay in the payment window you only need to enable it on the QuickPay website.

To natively query the MobilePay App for a better app experience you need to make some changes to your project settings, and implement the payment flow in a specific way. Follow the steps below and you will be ready to go.

#### Step 1) URL Schemes

To open the MobilePay App you need to whitelist the `mobilepayonline` url scheme. This is used to query the MobilePay App with the needed information for MobilePay to handle the authorization of a payment.

You also need to specify a url scheme for the MobilePay App to query back to when it is done doing its job. It is recommended to specify a scheme that is only used for this purpose since it will make your work later on easier.

#### Step 2) Payment flow with MobilePay

To use MobilePay native


#### Step 2) AppDelegate

WRITING IN PROGRESS








#### Callback

WRITING IN PROGRESS


### Apple Pay

WRITING IN PROGRESS
