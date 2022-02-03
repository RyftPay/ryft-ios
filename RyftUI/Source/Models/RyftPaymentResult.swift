import RyftCore

public enum RyftPaymentResult {
    case failed(error: RyftPaymentError)
    case pendingAction(
        paymentSession: PaymentSession,
        requiredAction: PaymentSessionRequiredAction
     )
    case success(paymentSession: PaymentSession)
}
