import RyftCore

final class MockRyftApiClient: RyftApiClient {

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
        completion(.failure(HttpError.general(message: "API response [get-payment]")))
    }
}
