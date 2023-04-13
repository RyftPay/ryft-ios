import RyftCore

public enum RyftPaymentResult {
    case cancelled
    case failed(error: RyftPaymentError)
    case pendingAction(
        paymentSession: PaymentSession,
        requiredAction: PaymentSessionRequiredAction
     )
    case success(paymentSession: PaymentSession)
}
