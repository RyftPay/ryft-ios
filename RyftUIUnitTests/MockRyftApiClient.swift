import RyftCore

final class MockRyftApiClient: RyftApiClient {

    var paymentSession: PaymentSession?

    func attemptPayment(
        request: AttemptPaymentRequest,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        completion(.failure(HttpError.general(message: "API response [attempt-payment]")))
    }

    func getPaymentSession(
        id: String,
        clientSecret: String,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        guard let paymentSession = paymentSession else {
            completion(.failure(HttpError.general(message: "API response [get-payment]")))
            return
        }
        completion(.success(paymentSession))
    }
}
