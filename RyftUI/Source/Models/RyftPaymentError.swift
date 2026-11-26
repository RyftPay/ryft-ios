import RyftCore

public struct RyftPaymentError {

    public let paymentSessionError: PaymentSessionError
    public let displayError: String
    public let errorCode: String?
    public let errorMessage: String?
    public let threeDsError: RyftThreeDsError?

    init(
        paymentSessionError: PaymentSessionError,
        errorCode: String? = nil,
        errorMessage: String? = nil,
        threeDsError: RyftThreeDsError? = nil
    ) {
        self.paymentSessionError = paymentSessionError
        self.displayError = NSLocalizedStringUtility.getStringWithFallback(
            forKey: paymentSessionError.rawValue
        )
        self.errorCode = errorCode
        self.errorMessage = errorMessage
        self.threeDsError = threeDsError
    }

    static func from(
        error: Error?,
        paymentSessionError: PaymentSessionError = .unknown
    ) -> RyftPaymentError {
        if let threeDsError = error as? RyftThreeDsError {
            return RyftPaymentError(
                paymentSessionError: paymentSessionError,
                errorCode: threeDsError.errorCode,
                errorMessage: threeDsError.errorDescription ?? threeDsError.type.rawValue,
                threeDsError: threeDsError
            )
        }
        guard let httpError = error as? HttpError else {
            return RyftPaymentError(
                paymentSessionError: paymentSessionError,
                errorMessage: error.map { String(describing: $0) }
            )
        }
        switch httpError {
        case .general(let message), .preRequest(let message):
            return RyftPaymentError(paymentSessionError: paymentSessionError, errorMessage: message)
        case .badResponse(let detail):
            guard let apiError = detail.body.errors.first else {
                return RyftPaymentError(paymentSessionError: paymentSessionError)
            }
            let code = apiError.code.trimmingCharacters(in: .whitespacesAndNewlines)
            let message = apiError.message.trimmingCharacters(in: .whitespacesAndNewlines)
            return RyftPaymentError(
                paymentSessionError: paymentSessionError,
                errorCode: code.isEmpty ? nil : apiError.code,
                errorMessage: message.isEmpty ? nil : apiError.message
            )
        }
    }
}
