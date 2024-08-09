import RyftUI

class ApplePayComponentDelegateTester: RyftApplePayComponentDelegate {

    var status: RyftApplePayComponent.RyftApplePayPaymentStatus?

    func applePayPayment(finishedWith status: RyftApplePayComponent.RyftApplePayPaymentStatus) {
        self.status = status
    }
}
