import RyftCore

final class MockRyftApiClient: RyftApiClient {

    var environment: RyftEnvironment = .sandbox

    var accountId: String?
    var paymentSession: PaymentSession?
    var attemptPaymentRequest: AttemptPaymentRequest?
    var didCallGetPaymentSession = false

    func attemptPayment(
        request: AttemptPaymentRequest,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        self.accountId = accountId
        attemptPaymentRequest = request
        guard let paymentSession = paymentSession else {
            completion(.failure(HttpError.general(message: "API response [attempt-payment]")))
            return
        }
        completion(.success(paymentSession))
    }

    func getPaymentSession(
        id: String,
        clientSecret: String,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        self.accountId = accountId
        didCallGetPaymentSession = true
        guard let paymentSession = paymentSession else {
            completion(.failure(HttpError.general(message: "API response [get-payment]")))
            return
        }
        completion(.success(paymentSession))
    }
}
