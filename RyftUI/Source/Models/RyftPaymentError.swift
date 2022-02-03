import RyftCore

public struct RyftPaymentError {

    public let paymentSessionError: PaymentSessionError
    public let displayError: String

    init(paymentSessionError: PaymentSessionError) {
        self.paymentSessionError = paymentSessionError
        self.displayError = NSLocalizedStringUtility.getStringWithFallback(
            forKey: paymentSessionError.rawValue
        )
    }
}
