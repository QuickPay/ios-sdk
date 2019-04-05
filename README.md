# QuickPay SDK

QuickPay SDK wraps the [QuickPay API](https://learn.quickpay.net/tech-talk/api/services/#services "QuickPay API") and provides the necessary functionality to add native payments to your app.

## Installation

You can install the QuickPay SDK either by downloading it directly from the GitHub repo or by using CocoaPods. If you want to use CocoaPods you can copy the example Podfile below.

```ruby
platform :ios, '11.0'

target '<YOUR_PROJECT_NAME>' do
  use_frameworks!

  pod 'QuickPaySDK'
end
```

### Fat library

The SDK is build as a fat library meaning it contains symbols for both the simulator and device architectures so you can develop on both platforms. Unfortunately Apple requires you to remove all simulator related symbols before submitting your app. The easiest way to do this is to add an additional build step that strips the unused architectures. Select your build target, go to `Build Phases` and add a new run script phase. Copy and paste the code below into your script and you will be good to go.

```bash
echo "Target architectures: $ARCHS"

APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"

find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"
echo $(lipo -info "$FRAMEWORK_EXECUTABLE_PATH")

FRAMEWORK_TMP_PATH="$FRAMEWORK_EXECUTABLE_PATH-tmp"

# remove simulator's archs if location is not simulator's directory
case "${TARGET_BUILD_DIR}" in
*"iphonesimulator")
echo "No need to remove archs"
;;
*)
if $(lipo "$FRAMEWORK_EXECUTABLE_PATH" -verify_arch "i386") ; then
lipo -output "$FRAMEWORK_TMP_PATH" -remove "i386" "$FRAMEWORK_EXECUTABLE_PATH"
echo "i386 architecture removed"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_TMP_PATH" "$FRAMEWORK_EXECUTABLE_PATH"
fi
if $(lipo "$FRAMEWORK_EXECUTABLE_PATH" -verify_arch "x86_64") ; then
lipo -output "$FRAMEWORK_TMP_PATH" -remove "x86_64" "$FRAMEWORK_EXECUTABLE_PATH"
echo "x86_64 architecture removed"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_TMP_PATH" "$FRAMEWORK_EXECUTABLE_PATH"
fi
;;
esac

echo "Completed for executable $FRAMEWORK_EXECUTABLE_PATH"
echo $(lipo -info "$FRAMEWORK_EXECUTABLE_PATH")

done
```


## Usage
This guide will take you through the steps needed to integrate the QuickPay SDK with your code.


### Initialization
In your AppDelegate you need to initialize the SDK with your API key.   
```swift
QuickPay.initWith(apiKey: String)
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

The payment windows is the easiest and quickest way to get payments up and running, it is also the only way you can accept payments with credit cards through the QuickPay SDK. The payment window handles step 2 and 3 of the payment flow for you, so the order of operations looks like this.

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

If this succeeds a `QPPayment` will be given to you in the success handler. The next step is to generate a payment URL that you will need in order to display the web based payment window. The needed parameters for this request are wrapped in `QPCreatePaymentLinkParameters` and is needed in the constructor of a `QPCreatePaymentLinkRequest`. The parameters needs a payment id and the amount it needs to authorize. Send the request and wait for the response.

```swift
let linkParams = QPCreatePaymentLinkParameters(id: payment.id, amount: 100)
let linkRequest = QPCreatePaymentLinkRequest(parameters: linkParams)

linkRequest.sendRequest(success: { (paymentLink) in
    // Handle the paymentLink
}, failure: { (data, response, error) in
    // Handle the failure
})
```

The last step is to use the `QPPaymentLink` to open the payment window. This is is done by parsing the paymentLink to the QuickPay class.

```swift
QuickPay.openLink(paymentLink: paymentLink, onCancel: {
    // Handle if the user cancels
}, onResponse: { (success) in
    // Handle success/failure
}
```

If success is true the payment has been handled but we do not yet know if the payment has actually been authorized. For that we need to check the status of the payment which is done with the `QPGetPaymentRequest`.

```swift
QPGetPaymentRequest(id: payment.id).sendRequest(success: { (payment) in
    if payment.accepted {
        // The payment has been authorized 👍
    }
}, failure: { (data, response, error) in
    // Handle the failure
})
```

### MobilePay

QuickPay SDK supports MobilePay natively so you can create a great app experience. To natively query the MobilePay App you need to make some changes to your project settings, and implement the payment flow in a specific way.

It is recommended that you check if the users has MobilePay installed and only show the payment option if it is available. The QuickPay class can help you with this.

```swift
QuickPay.isMobilePayAvailable()
```

#### URL Schemes for MobilePay

To open the MobilePay App you need to add the `mobilepayonline` url scheme to the `LSApplicationQueriesSchemes` array in your Info.plist. This is used to query the MobilePay App with the needed information for MobilePay to handle the authorization of a payment.

You also need to specify a url scheme for the MobilePay App to query back to when it is done doing its job. This is done in the `URL types` array in your Info.plist.

You can read more about the URL schemes on [https://developers.apple.com](https://developer.apple.com/documentation/uikit/core_app/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app)

#### Payment flow for MobilePay

First you need to create a payment just like with the payment window, but after that the flow is different since we do not have the payment window to handle a lot of tasks for us.

When you have created your payment you need to start a payment session and add some extra information to start a MobilePay session. Create a `MobilePayParameters` object and specify the URL scheme that you created earlier. You can also specify the language of MobilePay and add a URL to a logo you want it to display. Add these information to a `CreatePaymenSessionParameters` along with the amount of money you want to authorize. Finally put everything together in a `QPCreatePaymenSessionRequest` and send the request.

```swift
let mobilePayParameters = MobilePayParameters(returnUrl: "quickpayexampleshop://", language: "dk", shopLogoUrl: "https://SomeUrl/SomeImage.png")
let sessionParameters = CreatePaymenSessionParameters(amount: 100, mobilePay: mpp)

let request = QPCreatePaymenSessionRequest(id: payment.id, parameters: sessionParameters)

request.sendRequest(success: { (payment) in
    // Handle the payment
}, failure: { (data, response, error) in
    // Handle the failure
})
```

With the payment containing a session id we can now query MobilePay to authorize the payment.

```swift
QuickPay.authorizeWithMobilePay(payment: payment, completion: { (payment) in {
    // Handle the payment
}, failure: {
    // Handle the failure
}
```

In the completion handler we need to check the status of the payment. This is done in the same way as with the payment window. Create a `QPGetPaymentRequest` with the payment id and check if the updated payment is accepted.

### Apple Pay

Recomended reading  
https://www.weareintersect.com/news-and-insights/better-guide-setting-apple-pay/
