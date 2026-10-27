import RyftCore

public struct RyftPaymentError {

    public let paymentSessionError: PaymentSessionError
    public let displayError: String
    public let errorCode: String?
    public let errorMessage: String?

    init(
        paymentSessionError: PaymentSessionError,
        errorCode: String? = nil,
        errorMessage: String? = nil
    ) {
        self.paymentSessionError = paymentSessionError
        self.displayError = NSLocalizedStringUtility.getStringWithFallback(
            forKey: paymentSessionError.rawValue
        )
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }

    static func from(error: Error?) -> RyftPaymentError {
        guard case .badResponse(let detail)? = error as? HttpError,
              let apiError = detail.body.errors.first else {
            return RyftPaymentError(paymentSessionError: .unknown)
        }
        let code = apiError.code.trimmingCharacters(in: .whitespacesAndNewlines)
        let message = apiError.message.trimmingCharacters(in: .whitespacesAndNewlines)
        return RyftPaymentError(
            paymentSessionError: .unknown,
            errorCode: code.isEmpty ? nil : apiError.code,
            errorMessage: message.isEmpty ? nil : apiError.message
        )
    }
}
