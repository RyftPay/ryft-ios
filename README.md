# Ryft iOS

[![build-and-test](https://github.com/RyftPay/ryft-ios/actions/workflows/build-and-test.yml/badge.svg?branch=master)](https://github.com/RyftPay/ryft-ios/actions/workflows/build-and-test.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Ryft for iOS allows you to accept in-app payments securely and safely using our customisable UI elements.

<img src="images/drop-in-light-applepay.png" width=30% height=30%> <img src="images/drop-in-dark-applepay.png" width=30% height=30%>

## Requirements

- iOS 12.0+
- Xcode 15.0+
- Swift 5+

## Installation

Ryft iOS is available via:

- [Swift Package Manager](https://swift.org/package-manager/)

### Swift Package Manager

See Apple's [Guide](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) on how to add Swift packages to your app.

Use https://github.com/RyftPay/ryft-ios as the repository URL.

## Usage

The drop-in component provides you with all the necessary functions in order to enter and pay with your customer's card details.

The drop-in will handle formatting and input error as your user's type.

For the following steps, ensure you've imported the relevant Ryft packages:

```swift
import RyftCore
import RyftUI
```

### Initialising the drop-in

You should store and initialise the drop-in on the view which handles your checkout process.

```swift
private var ryftDropIn: RyftDropInPaymentViewController?

@objc private func showDropIn() {
    ryftDropIn = RyftDropInPaymentViewController(
        config: RyftDropInConfiguration(
            clientSecret: "<the client secret of the payment-session>",
            accountId: "nil | <the Id of the sub-account you are taking payments for>"
        ),
        publicApiKey: "<your public API key",
        delegate: self
    )
    present(ryftDropIn!, animated: true, completion: nil)
}
```

Under the hood the drop-in will detect the appropriate environment based on your public API key.

#### Optional: Collecting name on card

The drop-in can be configured to also collect the name on the card the customer pays with.

Note: This can help in reducing chargebacks and fraud. Additionally:
 - can lead to increased approval rates
 - can influence 3D-secure (more frequent frictionless flows)
 
 To collect this field, supply the `fieldCollection` object with `nameOnCard: true` when initialising the `RyftDropInConfiguration`:
 
 **Example:**

```swift
RyftDropInConfiguration(
    clientSecret: "<the client secret of the payment-session>",
    accountId: "nil | <the Id of the sub-account you are taking payments for>",
    fieldCollection: RyftDropInConfiguration.RyftDropInFieldCollectionConfig(
        nameOnCard: true
    )
)
```

### Implementing the RyftDropInPaymentDelegate

Once the customer has submitted their payment, the drop-in will dismiss.

To handle the result, the following methods of `RyftDropInPaymentDelegate` need to be implemented:

```swift
func onPaymentResult(result: RyftPaymentResult)
```

This method is invoked once the customer has entered their payment method details and submitted the payment

**Example:**

```swift
func onPaymentResult(result: RyftPaymentResult) {
    switch result {
    // payment approved, send the customer to your receipt/success view
    case .success(let paymentSession):
        showSuccessView()
    // payment requires an additional action in order to be approved (e.g. 3ds)
    case .pendingAction(let paymentSession, let requiredAction):
        // instruct the drop-in to handle the action
        ryftDropIn?.handleRequiredAction(
            returnUrl: URL(string: paymentSession.returnUrl),
            requiredAction
        )
    // payment failed, show an alert to the customer
    // `error.displayError` provides a human friendly message you can display
    case .failed(let error):
        let alert = UIAlertController(
            title: "Error taking payment",
            message: error.displayError,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Try again", style: .default) { _ in
            self.showDropIn()
        })
        present(alert, animated: true, completion: nil)
    }
    // drop in was cancelled prior to attempting payment
    case .cancelled:
        // you may want to log that the payment was cancelled here
}
```

## Adding Apple Pay

If you want to offer Apple Pay then simply add the necessary config when initialising the drop-in:

```swift
@objc private func showDropIn() {
    ryftDropIn = RyftDropInPaymentViewController(
        config: RyftDropInConfiguration(
            clientSecret: "<the client secret of the payment-session>",
            accountId: "nil | <the Id of the sub-account you are taking payments for>",
            applePay: RyftApplePayConfig(
                merchantIdentifier: "merchant.com.<you>",
                merchantCountryCode: "GB",
                merchantName: "<your merchant name to display on the Apple Pay sheet>"
            )
        ),
        publicApiKey: "<your public API key",
        delegate: self
    )
    present(ryftDropIn!, animated: true, completion: nil)
}
```

We will automatically display Apple Pay as an option provided your config is correct and the customer has an eligible card setup in their wallet.

### Using Apple Pay as a standalone payment option

It's considered best practice to offer Apple Pay as early as possible. For example, you may want to display it as early as a product listing/product page.

You can use our `RyftApplePayComponent` by itself (without the drop-in controller) if you wish to facilitate this.

#### Initialise the component

You can initialise the component in one of two ways:

- `RyftApplePayComponentConfig.auto` - let Ryft construct and populate the information on the Apple Pay sheet
- `RyftApplePayComponent.manual` - handle constructing Apple's `PKPaymentRequest` yourself

We recommend using `.auto`. This ensures that the financials displayed to the customer match what Ryft expects when authorizing the payment and reduces the chance of the payment failing due to an inconsistency on the client-side and backend.

```swift
@objc private func applePayButtonClicked() {
    let config = RyftApplePayConfig(
        merchantIdentifier: "<your merchant ID>",
        merchantCountryCode: "GB",
        merchantName: "<your merchant name to display on the Apple Pay sheet>"
    )
    // assign a fresh instance each time you want to display the ApplePay sheet
    self.applePayComponent = RyftApplePayComponent(
        publicApiKey: "<your public API key>",
        clientSecret: config.clientSecret,
        accountId: "nil | <the Id of the sub-account you are taking payments for>",
        config: .auto(config: config),
        delegate: self
    )
    self.applePayComponent?.present { presented in
        if !presented {
            /*
            * something went wrong with presenting the ApplePay sheet
            * show an alert or retry
            */
            self.applePayButton.isEnabled = true
        }
    }
}
```

#### Implementing the RyftApplePayComponentDelegate

Once the customer has submitted their payment, the drop-in will dismiss.

To handle the result, the following methods of `RyftDropInPaymentDelegate` need to be implemented:

```swift
func applePayPayment(
    finishedWith status: RyftApplePayComponent.RyftApplePayPaymentStatus
)
```

This method is invoked with one of several states:

```swift
 // user dismissed/cancelled the Apple Pay sheet
case cancelled
// either an unexpected error occurred or the payment failed to authorize
case error(error: Error?, paymentError: RyftPaymentError?)
// payment successful, show a receipt view
case success(paymentSession: PaymentSession)
```

**Example:**

```swift
public func applePayPayment(
    finishedWith status: RyftApplePayComponent.RyftApplePayPaymentStatus
) {
    applePayButton.isEnabled = true
    switch status {
    case .cancelled:
        break
    case .success(let paymentSession):
        /*
        * display your receipt/success view
        * the Ryft payment session is returned should you want to use
        * any of the values on it
        */
        showSuccessView()
    case .error(_, let paymentError):
        // payment failed, show an alert to the customer
        // `paymentError.displayError` provides a human friendly message you can display
        let alert = UIAlertController(
            title: "Error taking payment",
            message: error.displayError,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Try again", style: .default) { _ in
            self.applePayClicked()
        })
        present(alert, animated: true, completion: nil)
    }
}
```

### Using the drop-in for setting up cards for future use

A common use-case for some businesses is setting up and storing cards without charging the customer.
This is also known as zero-value authorization or account verification.

<img src="images/drop-in-setup-card.png" width=30% height=30%>

The drop-in currently has 2 usages:
 - `payment` (your customer is actively checking out and completing a purchase)
 - `setupCard` (your customer wants to save their card for future use without incurring any charges)

By default we will use `payment`, however to customise the view simply pass the `displayConfig` flag when initialising the drop-in:

```swift
RyftDropInConfiguration(
    clientSecret: "<the client secret of the payment-session>",
    accountId: nil, // account verifications must be done via the standard account holder.
    displayConfig: RyftDropInConfiguration.RyftDropInDisplayConfig(
        payButtonTitle: nil,
        usage: .setupCard
    )
    applePay: nil // we recommend leaving this nil to hide Apple Pay
)
```

### Handling Required Actions

Some payments will need additional steps after the initial payment attempt in order to be successfully authorized/settled (for example 3DS).
Our drop-in payment controller will handle these steps automatically for you, however you may wish or need to handle any required actions outside of checkout or by yourself if using your own UI.

A common use-case would be a MIT payment in which the bank still mandates that 3DS be performed to authorize the payment.
In this case you will need to bring your customer back online in your app/website and have them complete the necessary step.

You can use our `RyftRequiredActionComponent` by itself (without the drop-in controller) if you wish to facilitate this.

#### Initialise the component

Similarly to the drop-in controller, pass the payment session client secret and optional accountId (required for sub account payments) to your app:

```swift
private func initialiseRyftRequiredActionComponent() {
    let action = ... // fetch from your backend
    let config = RyftRequiredActionComponent.Configuration(
        clientSecret: config.clientSecret,
        accountId: "nil | <the Id of the sub-account you are taking payments for>"
    )
    // create a fresh instance each time
    let component = RyftRequiredActionComponent(
        config: config,
        apiClient: DefaultRyftApiClient(publicApiKey: "your public API key")
    )
    component.delegate = self
    component.handle(action: action)
}
```

#### Implementing the RyftRequiredActionComponentDelegate

Once you've called `handle`, the component will trigger any necessary actions against the Ryft API to complete it.

To handle the process in full, the following methods of `RyftRequiredActionComponentDelegate` need to be implemented:

```swift
public func onRequiredActionInProgress() {
    /*
    * (optional) 
    * the component is performing some asynchronous task
    * show your loading indicator/screen
    */
}

public func onRequiredActionHandled(result: Result<PaymentSession, Error>) {
    /*
    * The action has completed with either the updated PaymentSession, or an Error
    */
    switch result:
    case success(let updatedPaymentSession):
        // inspect the status to determine the next step
    case failure(let error):
        // handle the error (try again/show an alert)
        print("error handling required action \(error)")
}
```

### Customising the drop-in

You can customise the appearance the drop-in by passing in your own `RyftUITheme` instance.

**Example:**

```swift
let myTheme = RyftUITheme.defaultTheme
myTheme.separatorLineColor = .blue
// set various other colors
ryftDropIn = RyftDropInPaymentViewController(...)
ryftDropIn.theme = myTheme
present(ryftDropIn, animated: true, completion: nil)
```
