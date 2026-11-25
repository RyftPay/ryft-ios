import XCTest
import RyftCore
import PassKit

@testable import RyftUI

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

    func test_hasSucceeded_shouldReturnTrue_whenStatusIsApprovedOrCaptured() {
        XCTAssertTrue(TestFixtures.paymentSession(status: .approved).hasSucceeded)
        XCTAssertTrue(TestFixtures.paymentSession(status: .captured).hasSucceeded)
    }

    func test_hasSucceeded_shouldReturnFalse_whenStatusIsNotApprovedOrCaptured() {
        XCTAssertFalse(TestFixtures.paymentSession(status: .pendingPayment).hasSucceeded)
        XCTAssertFalse(TestFixtures.paymentSession(status: .pendingAction).hasSucceeded)
        XCTAssertFalse(TestFixtures.paymentSession(status: .unknown).hasSucceeded)
    }

    func test_isAwaitingOutcome_shouldReturnTrue_whenStatusIsUnknownWithNoErrorOrAction() {
        XCTAssertTrue(TestFixtures.paymentSession(status: .unknown).isAwaitingOutcome)
    }

    func test_isAwaitingOutcome_shouldReturnFalse_whenStatusIsKnown() {
        XCTAssertFalse(TestFixtures.paymentSession(status: .approved).isAwaitingOutcome)
        XCTAssertFalse(TestFixtures.paymentSession(status: .captured).isAwaitingOutcome)
        XCTAssertFalse(TestFixtures.paymentSession(status: .pendingPayment).isAwaitingOutcome)
        XCTAssertFalse(TestFixtures.paymentSession(status: .pendingAction).isAwaitingOutcome)
    }

    func test_isAwaitingOutcome_shouldReturnFalse_whenSessionHasLastError() {
        let paymentSession = TestFixtures.paymentSession(status: .unknown, lastError: .gatewayReject)
        XCTAssertFalse(paymentSession.isAwaitingOutcome)
    }

    func test_isAwaitingOutcome_shouldReturnFalse_whenSessionHasRequiredAction() {
        let paymentSession = TestFixtures.paymentSession(
            challengeAction: TestFixtures.challengeAction(),
            status: .unknown
        )
        XCTAssertFalse(paymentSession.isAwaitingOutcome)
    }

    func test_hasPendingChallenge_shouldReturnTrue_whenSameChallengeIsPendingWithNoError() {
        let paymentSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
        XCTAssertTrue(paymentSession.hasPendingChallenge(threeDSServerTransactionId: "3ds_txn_123"))
    }

    func test_hasPendingChallenge_shouldReturnFalse_whenChallengeIsDifferent() {
        let paymentSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
        XCTAssertFalse(paymentSession.hasPendingChallenge(threeDSServerTransactionId: "3ds_txn_456"))
    }

    func test_hasPendingChallenge_shouldReturnFalse_whenSessionHasLastError() {
        let paymentSession = TestFixtures.paymentSession(
            challengeAction: TestFixtures.challengeAction(),
            lastError: .threeDSecureAuthenticationFailure
        )
        XCTAssertFalse(paymentSession.hasPendingChallenge(threeDSServerTransactionId: "3ds_txn_123"))
    }

    func test_hasPendingChallenge_shouldReturnFalse_whenSessionHasNoRequiredAction() {
        let paymentSession = TestFixtures.paymentSession(status: .captured)
        XCTAssertFalse(paymentSession.hasPendingChallenge(threeDSServerTransactionId: "3ds_txn_123"))
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
