import RyftCore

enum RyftPaymentState {
    case notStarted
    case processing
    case failed(
        error: Error?,
        _ ryftError: RyftPaymentError?
    )
    case complete(_ paymentSession: PaymentSession)
}
