import RyftCore

public enum RyftPaymentResult {
    case cancelled
    case failed(error: RyftPaymentError)
    case success(paymentSession: PaymentSession)
}
