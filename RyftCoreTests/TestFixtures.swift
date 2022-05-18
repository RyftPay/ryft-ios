@testable import RyftCore

final class TestFixtures {

    static func paymentSession() -> PaymentSession {
        return PaymentSession(
            id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
            amount: 350,
            currency: "GBP",
            status: .approved,
            lastError: nil,
            requiredAction: nil,
            returnUrl: "https://ryftpay.com",
            createdTimestamp: 123
        )
    }
}
