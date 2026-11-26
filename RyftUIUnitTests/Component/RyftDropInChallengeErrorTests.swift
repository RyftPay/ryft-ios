import XCTest
import RyftCore

@testable import RyftUI

final class RyftDropInChallengeErrorTests: XCTestCase {

    private let threeDsError = RyftThreeDsError(
        type: .protocolError,
        errorCode: "201",
        errorComponent: "C",
        errorDescription: "Required element missing",
        errorDetail: "oobContinueLabel"
    )

    func test_onRequiredActionHandled_shouldReturnThreeDsError_whenChallengeFailedAndSessionHasLastError() {
        let delegate = DropInDelegateTester()
        let dropIn = createDropIn(delegate: delegate)

        dropIn.onRequiredActionChallengeFailed(error: threeDsError)
        dropIn.onRequiredActionHandled(result: .success(failedSession()))

        let error = failedError(delegate.result)
        XCTAssertEqual(error?.paymentSessionError, .threeDSecureAuthenticationFailure)
        XCTAssertEqual(error?.threeDsError, threeDsError)
        XCTAssertEqual(error?.errorCode, "201")
        XCTAssertEqual(error?.errorMessage, "Required element missing")
    }

    func test_onRequiredActionHandled_shouldReturnThreeDsError_whenResultIsThreeDsFailure() {
        let delegate = DropInDelegateTester()
        let dropIn = createDropIn(delegate: delegate)

        dropIn.onRequiredActionChallengeFailed(error: threeDsError)
        dropIn.onRequiredActionHandled(result: .failure(threeDsError))

        let error = failedError(delegate.result)
        XCTAssertEqual(error?.paymentSessionError, .unknown)
        XCTAssertEqual(error?.threeDsError, threeDsError)
    }

    func test_onRequiredActionHandled_shouldNotReturnThreeDsError_whenNoChallengeFailed() {
        let delegate = DropInDelegateTester()
        let dropIn = createDropIn(delegate: delegate)

        dropIn.onRequiredActionHandled(result: .success(failedSession()))

        let error = failedError(delegate.result)
        XCTAssertEqual(error?.paymentSessionError, .threeDSecureAuthenticationFailure)
        XCTAssertNil(error?.threeDsError)
        XCTAssertNil(error?.errorCode)
        XCTAssertNil(error?.errorMessage)
    }

    func test_onRequiredActionHandled_shouldReturnSuccess_whenChallengeFailedAndPaymentSucceeded() {
        let delegate = DropInDelegateTester()
        let dropIn = createDropIn(delegate: delegate)

        dropIn.onRequiredActionChallengeFailed(error: threeDsError)
        dropIn.onRequiredActionHandled(result: .success(TestFixtures.paymentSession(status: .captured)))

        guard case .success? = delegate.result else {
            XCTFail("expected .success but got \(String(describing: delegate.result))")
            return
        }
    }

    private func failedSession() -> PaymentSession {
        TestFixtures.paymentSession(
            status: .pendingPayment,
            lastError: .threeDSecureAuthenticationFailure
        )
    }

    private func failedError(
        _ result: RyftPaymentResult?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> RyftPaymentError? {
        guard case .failed(let error)? = result else {
            XCTFail("expected .failed but got \(String(describing: result))", file: file, line: line)
            return nil
        }
        return error
    }

    private func createDropIn(delegate: RyftDropInPaymentDelegate) -> RyftDropInPaymentViewController {
        RyftDropInPaymentViewController(
            config: RyftDropInConfiguration(clientSecret: "secret"),
            apiClient: MockRyftApiClient(),
            delegate: delegate
        )
    }
}

private final class DropInDelegateTester: RyftDropInPaymentDelegate {

    var result: RyftPaymentResult?

    func onPaymentResult(result: RyftPaymentResult) {
        self.result = result
    }
}
