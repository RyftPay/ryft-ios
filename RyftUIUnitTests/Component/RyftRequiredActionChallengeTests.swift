import XCTest
import UIKit

@testable import RyftCore
@testable import RyftUI

final class RyftRequiredActionChallengeTests: XCTestCase {

    private let presenter = UIViewController()

    func test_handle_shouldNotReportChallengeResult_whenChallengeIsCancelled() {
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        threeDsHandler.challengeResult = .cancelled
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
        let component = createComponent(apiClient: apiClient, threeDsActionHandler: threeDsHandler)

        component.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        XCTAssertEqual(apiClient.continuePaymentRequests.count, 1)
    }

    func test_handle_shouldReportSdkTransactionStatus_whenChallengeCompletes() {
        let challengeAction = TestFixtures.challengeAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        threeDsHandler.challengeResult = .completed(
            transactionStatus: "Y",
            threeDSServerTransactionId: challengeAction.threeDSServerTransactionId
        )
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = TestFixtures.paymentSession(challengeAction: challengeAction)
        let component = createComponent(apiClient: apiClient, threeDsActionHandler: threeDsHandler)

        component.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        assertReportedChallengeResult(
            apiClient,
            transStatus: "Y",
            threeDSServerTransactionId: challengeAction.threeDSServerTransactionId
        )
    }

    func test_handle_shouldReportUnknownTransactionStatus_whenChallengeTimesOut() {
        assertChallengeFailureIsReported(RyftThreeDsError(type: .timeout))
    }

    func test_handle_shouldReportUnknownTransactionStatus_whenChallengeFailsWithProtocolError() {
        assertChallengeFailureIsReported(RyftThreeDsError(type: .protocolError, errorCode: "201"))
    }

    func test_handle_shouldReportUnknownTransactionStatus_whenChallengeFailsWithRuntimeError() {
        assertChallengeFailureIsReported(RyftThreeDsError(type: .runtimeError, errorDescription: "runtime error"))
    }

    func test_handle_shouldNotifyDelegateWithReportedSession_whenChallengeFails() {
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        threeDsHandler.challengeResult = .failed(error: RyftThreeDsError(type: .timeout))
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession())
        ]
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )

        component.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        switch delegate.result {
        case .success(let session):
            XCTAssertEqual(session.status, .approved)
            XCTAssertNil(session.requiredAction)
        default:
            XCTFail("expected .success but got \(String(describing: delegate.result))")
        }
    }

    func test_handle_shouldNotifyDelegateWithProcessedSession_whenReportingChallengeFailureFails() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleFailedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertSuccess(delegate.result, status: .captured)
    }

    func test_handle_shouldNotifyDelegateChallengeError_whenReportingChallengeFailureFailsAndChallengeStaysPending() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.paymentSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
        let delegate = RyftRequiredActionDelegateTester()

        handleFailedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 15)
        assertChallengeFailure(delegate.result)
    }

    func test_handle_shouldNotifyDelegateChallengeError_whenReportingChallengeFailureFailsAndSessionCannotBeRead() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [
            .failure(HttpError.general(message: "API response [get-payment]"))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleFailedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertChallengeFailure(delegate.result)
    }

    func test_handle_shouldNotifyDelegateWithSettledSession_whenReportedChallengeFailureResponseIsNotFinal() {
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

        handleFailedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 2)
        assertSuccess(delegate.result, status: .captured)
    }

    func test_handle_shouldNotifyDelegateOfChallengeError_whenChallengeFails() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(lastError: .threeDSecureAuthenticationFailure))
        ]
        let delegate = RyftRequiredActionDelegateTester()
        var challengeErrorWhenHandled: RyftThreeDsError?
        delegate.onHandled = { challengeErrorWhenHandled = delegate.challengeError }

        handleFailedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(challengeErrorWhenHandled, RyftThreeDsError(type: .timeout))
    }

    func test_handle_shouldNotifyDelegateOfRuntimeError_whenChallengeFailsWithOtherError() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .success(TestFixtures.paymentSession(lastError: .threeDSecureAuthenticationFailure))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleChallenge(
            result: .failed(error: RyftRequiredActionError.missingIdentifyDetails),
            apiClient: apiClient,
            delegate: delegate
        )

        XCTAssertEqual(
            delegate.challengeError,
            RyftThreeDsError(type: .runtimeError, errorDescription: "missingIdentifyDetails")
        )
    }

    func test_handle_shouldNotifyDelegateFailureWithRuntimeError_whenOtherErrorCannotBeReported() {
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())),
            .failure(HttpError.general(message: "API response [continue-payment]"))
        ]
        apiClient.getPaymentSessionResults = [.failure(HttpError.general(message: "API response [get]"))]
        let delegate = RyftRequiredActionDelegateTester()

        handleChallenge(
            result: .failed(error: RyftRequiredActionError.missingIdentifyDetails),
            apiClient: apiClient,
            delegate: delegate
        )

        guard case .failure(let error)? = delegate.result else {
            XCTFail("expected .failure but got \(String(describing: delegate.result))")
            return
        }
        XCTAssertEqual(
            error as? RyftThreeDsError,
            RyftThreeDsError(type: .runtimeError, errorDescription: "missingIdentifyDetails")
        )
    }

    func test_handle_shouldNotNotifyDelegateOfChallengeError_whenChallengeCompletes() {
        let challengeAction = TestFixtures.challengeAction()
        let apiClient = MockRyftApiClient()
        apiClient.continuePaymentResults = [
            .success(TestFixtures.paymentSession(challengeAction: challengeAction)),
            .success(TestFixtures.paymentSession(status: .captured))
        ]
        let delegate = RyftRequiredActionDelegateTester()

        handleChallenge(
            result: .completed(
                transactionStatus: "Y",
                threeDSServerTransactionId: challengeAction.threeDSServerTransactionId
            ),
            apiClient: apiClient,
            delegate: delegate
        )

        XCTAssertNil(delegate.challengeError)
    }

    func test_handle_shouldNotNotifyDelegateOfChallengeError_whenChallengeIsCancelled() {
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
        let delegate = RyftRequiredActionDelegateTester()

        handleChallenge(result: .cancelled, apiClient: apiClient, delegate: delegate)

        XCTAssertNil(delegate.challengeError)
    }

    func test_handle_shouldCallCleanup_whenChallengeFails() {
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        threeDsHandler.challengeResult = .failed(error: RyftThreeDsError(type: .timeout))
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = TestFixtures.paymentSession(challengeAction: TestFixtures.challengeAction())
        let component = createComponent(apiClient: apiClient, threeDsActionHandler: threeDsHandler)

        component.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        XCTAssertEqual(apiClient.continuePaymentRequests.count, 2)
        XCTAssertTrue(threeDsHandler.cleanupInvoked)
    }

    func test_handle_shouldNotifyDelegateChallengeError_whenReportingChallengeFailureFailsAndSessionHasSettled() {
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

        handleFailedChallenge(apiClient: apiClient, delegate: delegate)

        XCTAssertEqual(apiClient.getPaymentSessionRequestCount, 1)
        assertChallengeFailure(delegate.result)
    }

    private func handleFailedChallenge(
        apiClient: MockRyftApiClient,
        delegate: RyftRequiredActionDelegateTester
    ) {
        handleChallenge(
            result: .failed(error: RyftThreeDsError(type: .timeout)),
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

    private func assertChallengeFailure(
        _ result: RyftRequiredActionResult?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        switch result {
        case .failure(let error):
            XCTAssertEqual(error as? RyftThreeDsError, RyftThreeDsError(type: .timeout), file: file, line: line)
        default:
            XCTFail("expected .failure but got \(String(describing: result))", file: file, line: line)
        }
    }

    private func assertChallengeFailureIsReported(
        _ error: Error,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let challengeAction = TestFixtures.challengeAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        threeDsHandler.challengeResult = .failed(error: error)
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = TestFixtures.paymentSession(challengeAction: challengeAction)
        let component = createComponent(apiClient: apiClient, threeDsActionHandler: threeDsHandler)

        component.handle(action: TestFixtures.identifyAction(), presentingViewController: presenter)

        assertReportedChallengeResult(
            apiClient,
            transStatus: "U",
            threeDSServerTransactionId: challengeAction.threeDSServerTransactionId,
            file: file,
            line: line
        )
    }

    private func assertReportedChallengeResult(
        _ apiClient: MockRyftApiClient,
        transStatus: String,
        threeDSServerTransactionId: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(apiClient.continuePaymentRequests.count, 2, file: file, line: line)
        guard let threeDs = apiClient.continuePaymentRequests.last?.toJson()["threeDs"] as? [String: Any],
              let encoded = threeDs["challengeResult"] as? String,
              let data = Data(base64Encoded: encoded),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String]
        else {
            XCTFail("expected a challenge result on the last continue payment request", file: file, line: line)
            return
        }
        XCTAssertEqual(json["transStatus"], transStatus, file: file, line: line)
        XCTAssertEqual(json["threeDSServerTransID"], threeDSServerTransactionId, file: file, line: line)
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
