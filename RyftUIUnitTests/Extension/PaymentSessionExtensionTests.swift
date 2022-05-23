import XCTest
import RyftCore

@testable import RyftUI
import PassKit

final class PaymentSessionExtensionTests: XCTestCase {

    func test_toPKPayment_shouldReturnExpectedResult_whenCustomerEmailIsNil() {
        let paymentSession = TestFixtures.paymentSession(customerEmail: nil)
        let result = paymentSession.toPKPayment(
            merchantIdentifier: "com.example.ryft",
            merchantCountry: "GB",
            merchantName: "Bob"
        )
        assertResult(result, paymentSession)
        XCTAssertEqual(result.requiredShippingContactFields, [.emailAddress])
    }

    func test_toPKPayment_shouldReturnExpectedResult_whenCustomerEmailIsNotNil() {
        let paymentSession = TestFixtures.paymentSession(customerEmail: "support@ryftpay.com")
        let result = paymentSession.toPKPayment(
            merchantIdentifier: "com.example.ryft",
            merchantCountry: "GB",
            merchantName: "Bob"
        )
        assertResult(result, paymentSession)
        XCTAssertEqual(result.requiredShippingContactFields, [])
    }

    private func assertResult(
        _ result: PKPaymentRequest,
        _ paymentSession: PaymentSession
    ) {
        XCTAssertEqual("com.example.ryft", result.merchantIdentifier)
        XCTAssertEqual("GB", result.countryCode)
        XCTAssertEqual(PKMerchantCapability.capability3DS, result.merchantCapabilities)
        XCTAssertEqual(paymentSession.currency, result.currencyCode)
        XCTAssertEqual(result.supportedNetworks, [.visa, .masterCard])
        XCTAssertEqual(result.requiredBillingContactFields, [.postalAddress])
        XCTAssertEqual(result.paymentSummaryItems, [
            PKPaymentSummaryItem(
                label: "Bob",
                amount: paymentSession.amountAsMoney().amountInMajorUnits(),
                type: .final
            )
        ])
    }
}
