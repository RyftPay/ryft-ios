import Foundation

public protocol RyftApiClient {

    typealias PaymentSessionResponse = (Result<PaymentSession, HttpError>) -> Void

    var environment: RyftEnvironment { get set }

    func attemptPayment(
        request: AttemptPaymentRequest,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    )

    func getPaymentSession(
        id: String,
        clientSecret: String,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    )
}
