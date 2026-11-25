import RyftCore

final class MockRyftApiClient: RyftApiClient {

    var environment: RyftEnvironment = .sandbox

    var accountId: String?
    var paymentSession: PaymentSession?
    var attemptPaymentRequest: AttemptPaymentRequest?
    var continuePaymentRequest: ContinuePaymentRequest?
    var continuePaymentRequests: [ContinuePaymentRequest] = []
    var continuePaymentResults: [Result<PaymentSession, HttpError>] = []
    var didCallGetPaymentSession = false
    var getPaymentSessionRequestCount = 0
    var getPaymentSessionResults: [Result<PaymentSession, HttpError>] = []

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

    func continuePayment(
        request: ContinuePaymentRequest,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        self.accountId = accountId
        continuePaymentRequest = request
        continuePaymentRequests.append(request)
        guard continuePaymentResults.isEmpty else {
            completion(continuePaymentResults.removeFirst())
            return
        }
        guard let paymentSession = paymentSession else {
            completion(.failure(HttpError.general(message: "API response [continue-payment]")))
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
        getPaymentSessionRequestCount += 1
        guard getPaymentSessionResults.isEmpty else {
            completion(getPaymentSessionResults.removeFirst())
            return
        }
        guard let paymentSession = paymentSession else {
            completion(.failure(HttpError.general(message: "API response [get-payment]")))
            return
        }
        completion(.success(paymentSession))
    }
}
