import RyftCore

final class MockRyftApiClient: RyftApiClient {

    var environment: RyftEnvironment = .sandbox

    var accountId: String?
    var paymentSession: PaymentSession?
    var attemptPaymentRequest: AttemptPaymentRequest?
    var continuePaymentRequest: ContinuePaymentRequest?
    var continuePaymentRequests: [ContinuePaymentRequest] = []
    var continuePaymentResults: [Result<PaymentSession, HttpError>] = []
    var deferContinuePaymentFromRequest: Int?
    private var deferredContinuePayments: [() -> Void] = []
    var didCallGetPaymentSession = false
    var getPaymentSessionRequestCount = 0
    var getPaymentSessionIds: [String] = []
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

    func completeDeferredContinuePayments() {
        let completions = deferredContinuePayments
        deferredContinuePayments = []
        completions.forEach { $0() }
    }

    private func nextContinuePaymentResult() -> Result<PaymentSession, HttpError> {
        guard continuePaymentResults.isEmpty else {
            return continuePaymentResults.removeFirst()
        }
        guard let paymentSession = paymentSession else {
            return .failure(HttpError.general(message: "API response [continue-payment]"))
        }
        return .success(paymentSession)
    }

    func continuePayment(
        request: ContinuePaymentRequest,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        self.accountId = accountId
        continuePaymentRequest = request
        continuePaymentRequests.append(request)
        let result = nextContinuePaymentResult()
        if let firstDeferred = deferContinuePaymentFromRequest, continuePaymentRequests.count >= firstDeferred {
            deferredContinuePayments.append { completion(result) }
            return
        }
        completion(result)
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
        getPaymentSessionIds.append(id)
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
