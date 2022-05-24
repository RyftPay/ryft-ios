@testable import RyftCore

final class TestFixtures {

    static func paymentSession() -> PaymentSession {
        return PaymentSession(
            id: "ps_01FCTS1XMKH9FF43CAFA4CXT3P",
            amount: 350,
            currency: "GBP",
            status: .approved,
            customerEmail: nil,
            lastError: nil,
            requiredAction: nil,
            returnUrl: "https://ryftpay.com",
            createdTimestamp: 123
        )
    }

    static func billingAddress() -> BillingAddress {
        BillingAddress(
            firstName: nil,
            lastName: nil,
            lineOne: nil,
            lineTwo: nil,
            city: nil,
            country: "US",
            postalCode: "94043",
            region: nil
        )
    }
}
