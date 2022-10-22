import RyftCore

final class TestFixtures {

    static func paymentSession(customerEmail: String? = nil) -> PaymentSession {
        PaymentSession(
            id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
            amount: 350,
            currency: "GBP",
            status: .approved,
            customerEmail: customerEmail,
            lastError: nil,
            requiredAction: nil,
            returnUrl: "https://ryftpay.com",
            createdTimestamp: 123
        )
    }

    static func identifyAction() -> PaymentSessionRequiredAction {
        PaymentSessionRequiredAction(
            type: .identify,
            url: nil,
            identify: RequiredActionIdentifyApp(
                sessionId: "session_123",
                sessionSecret: "secret",
                scheme: "mastercard",
                paymentMethodId: "pmt_01FCTS1XMKH9FF43CAFA4CXT3P")
            )
    }
}
