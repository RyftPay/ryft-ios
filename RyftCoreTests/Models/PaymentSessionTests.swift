import XCTest

@testable import RyftCore

class PaymentSessionTests: XCTestCase {

    func test_amountAsMoney_shouldReturnExpectedValue() {
        let paymentSession = TestFixtures.paymentSession()
        let expected = Money(
            currencyCode: paymentSession.currency,
            amount: paymentSession.amount
        )
        XCTAssertEqual(expected, paymentSession.amountAsMoney())
    }
}
