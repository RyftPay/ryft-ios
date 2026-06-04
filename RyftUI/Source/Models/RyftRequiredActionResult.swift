import RyftCore

public enum RyftRequiredActionResult {
    case success(PaymentSession)
    case cancelled
    case failure(Error)
}
