import XCTest
import UIKit

@testable import RyftCore
@testable import RyftUI

final class RyftRequiredActionSessionCheckTests: XCTestCase {

    private let presenter = UIViewController()

    func test_handle_shouldNotCheckSession_whenChallengeResultResponseIsFinal() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 0)
        assertSuccess(delegate.result, status: .captured)
    }

    func test_handle_shouldNotifyDelegateWithProcessedSession_whenChallengeResultCallFails() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertSuccess(delegate.result, status: .captured)
    }

    func test_handle_shouldCheckSessionWithChallengeSessionId_whenChallengeResultCallFails() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionIds, ["ps_01FCTS1XMKH9FF43CAFA4CXT3P"])
    }

    func test_handle_shouldNotifyDelegateWithProcessedSession_whenChallengeIsStillPendingOnFirstSessionCheck() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 2)
        assertSuccess(delegate.result, status: .captured)
    }

    func test_handle_shouldNotifyDelegateFailure_whenChallengeResultCallFailsAndChallengeStaysPending() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.paymentSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 15)
        assertHttpFailure(delegate.result)
    }

    func test_handle_shouldNotKeepCheckingSession_whenSessionHasDifferentRequiredAction() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(
                challengeAction: TestFixtures.challengeAction(threeDSServerTransactionId: "3ds_txn_456")
            ))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertHttpFailure(delegate.result)
    }

    func test_handle_shouldNotifyDelegateFailure_whenChallengeResultCallFailsAndSessionCannotBeRead() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .failure(HttpError.general(message: "API response [get-payment]"))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertHttpFailure(delegate.result)
    }

    func test_handle_shouldKeepCheckingSession_whenChallengeResultCallFailsAndSessionIsNotFinal() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .unknown)),
            .success(TestFixtures.paymentSession(status: .approved))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 2)
        assertSuccess(delegate.result, status: .approved)
    }

    func test_handle_shouldNotifyDelegateWithSettledSession_whenChallengeResultResponseIsNotFinal() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(status: .unknown))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .unknown)),
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 2)
        assertSuccess(delegate.result, status: .captured)
    }

    func test_handle_shouldKeepCheckingSession_whenChallengeResultResponseStillHasPendingChallenge() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction()))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertSuccess(delegate.result, status: .captured)
    }

    func test_handle_shouldNotCheckSession_whenChallengeResultResponseHasDifferentRequiredAction() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(
                challengeAction: TestFixtures.challengeAction(threeDSServerTransactionId: "3ds_txn_456")
            ))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 0)
        assertSuccess(delegate.result, status: .pendingAction)
    }

    func test_handle_shouldNotifyDelegateWithDeclinedSession_whenChallengeResultCallFailsAndSessionHasSettled() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(
                status: .pendingPayment,
                lastError: .threeDSecureAuthenticationFailure
            ))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        switch delegate.result {
        case .success(let session):
            XCTAssertEqual(session.lastError, .threeDSecureAuthenticationFailure)
        default:
            XCTFail("expected .success but got \(String(describing: delegate.result))")
        }
    }

    func test_handle_shouldNotifyDelegateWithLatestSession_whenLaterSessionCheckFails() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction()))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .unknown)),
            .failure(HttpError.general(message: "API response [get-payment]"))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 2)
        switch delegate.result {
        case .success(let session):
            XCTAssertEqual(session.status, .unknown)
            XCTAssertNil(session.requiredAction)
        default:
            XCTFail("expected .success but got \(String(describing: delegate.result))")
        }
    }

    func test_handle_shouldNotifyDelegateFailure_whenChallengeResultCallFailsAndLaterSessionCheckFails() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .unknown)),
            .failure(HttpError.general(message: "API response [get-payment]"))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 2)
        assertHttpFailure(delegate.result)
    }

    func test_handle_shouldNotifyDelegateWithFailedSession_whenSessionSettlesWithLastError() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(status: .unknown))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(
                status: .pendingPayment,
                lastError: .threeDSecureAuthenticationFailure
            ))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        switch delegate.result {
        case .success(let session):
            XCTAssertEqual(session.lastError, .threeDSecureAuthenticationFailure)
        default:
            XCTFail("expected .success but got \(String(describing: delegate.result))")
        }
    }

    func test_handle_shouldNotifyDelegateWithLastSession_whenSessionDoesNotSettle() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(status: .unknown))
        ]
        apiClient.paymentSession = TestFixtures.paymentSession(status: .unknown)
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 15)
        assertSuccess(delegate.result, status: .unknown)
    }

    func test_handle_shouldNotifyDelegateWithLastSession_whenSessionCannotBeRead() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(status: .unknown))
        ]
        apiClient.getPaymentSessionResults = [
            .failure(HttpError.general(message: "API response [get-payment]"))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleCompletedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertSuccess(delegate.result, status: .unknown)
    }

    private func handleCompletedChallenge(
        apiClient: MockRyftApiClient,
        delegate: RyftRequiredActionDelegateTester
    ) {
        handleChallenge(
            result: .completed(
                transactionStatus: "Y",
                threeDSServerTransactionId: TestFixtures.challengeAction().threeDSServerTransactionId
            ),
            apiClient: apiClient,
            delegate: delegate
        )
    }

    private func handleChallenge(
        result: ThreeDsChallengeResult,
        apiClient: MockRyftApiClient,
        delegate: RyftRequiredActionDelegateTester
    ) {
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        threeDsHandler.challengeResult = result
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )

        component.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        guard delegate.result == nil else {
            return
        }
        let handled = expectation(description: "required action handled")
        delegate.onHandled = { handled.fulfill() }
        wait(for: [handled], timeout: 2.0)
    }

    private func assertSuccess(
        _ result: RyftRequiredActionResult?,
        status: PaymentSessionStatus,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch result {
        case .success(let session):
            XCTAssertEqual(session.status, status, file: file, line: line)
        default:
            XCTFail("expected .success but got \(String(describing: result))", file: file, line: line)
        }
    }

    private func assertHttpFailure(
        _ result: RyftRequiredActionResult?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch result {
        case .failure(let error):
            XCTAssertTrue(error is HttpError, file: file, line: line)
        default:
            XCTFail("expected .failure but got \(String(describing: result))", file: file, line: line)
        }
    }

    private func createComponent(
        apiClient: RyftApiClient = MockRyftApiClient(),
        delegate: RyftRequiredActionDelegate? = nil,
        threeDsActionHandler: RyftThreeDsActionHandler
    ) -> RyftRequiredActionComponent {
        let component = RyftRequiredActionComponent(
            config: RyftRequiredActionComponent.Configuration(clientSecret: "secret"),
            apiClient: apiClient,
            threeDsActionHandler: threeDsActionHandler,
            sessionCheckInterval: 0
        )
        component.delegate = delegate
        return component
    }
}
