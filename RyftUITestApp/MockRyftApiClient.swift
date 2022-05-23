import RyftCore

final class MockRyftApiClient: RyftApiClient {

    var getPaymentSessionResult: Result<PaymentSession, HttpError> = .success(PaymentSession(
        id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
        amount: 350,
        currency: "GBP",
        status: .pendingPayment,
        customerEmail: nil,
        lastError: nil,
        requiredAction: nil,
        returnUrl: "https://ryftpay.com",
        createdTimestamp: 123
    ))

    var attemptPaymentResult: Result<PaymentSession, HttpError> = .success(PaymentSession(
        id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
        amount: 350,
        currency: "GBP",
        status: .approved,
        customerEmail: nil,
        lastError: nil,
        requiredAction: nil,
        returnUrl: "https://ryftpay.com",
        createdTimestamp: 123
    ))

    func attemptPayment(
        request: AttemptPaymentRequest,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        completion(attemptPaymentResult)
    }

    func getPaymentSession(
        id: String,
        clientSecret: String,
        accountId: String?,
        completion: @escaping PaymentSessionResponse
    ) {
        completion(getPaymentSessionResult)
    }
}
