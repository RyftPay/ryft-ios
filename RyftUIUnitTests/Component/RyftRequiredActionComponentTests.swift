import XCTest
import UIKit
import RyftCore

@testable import RyftUI

final class RyftRequiredActionComponentTests: XCTestCase {

    private let presenter = UIViewController()

    func test_handle_shouldCallCreateTransaction_whenGivenIdentifyAction() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        let component = createComponent(threeDsActionHandler: threeDsHandler)

        component.handle(action: action, presentingViewController: presenter)

        XCTAssertTrue(threeDsHandler.createTransactionInvoked)
        XCTAssertEqual(action.identify!, threeDsHandler.action)
    }

    func test_handle_shouldCallContinuePayment_afterSuccessfulCreateTransaction() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        let apiClient = MockRyftApiClient()
        let component = createComponent(apiClient: apiClient, threeDsActionHandler: threeDsHandler)

        component.handle(action: action, presentingViewController: presenter)

        XCTAssertNotNil(apiClient.continuePaymentRequest)
    }

    func test_handle_shouldNotifyDelegateInProgress_afterSuccessfulCreateTransaction() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(delegate: delegate, threeDsActionHandler: threeDsHandler)

        component.handle(action: action, presentingViewController: presenter)

        XCTAssertTrue(delegate.inProgress)
    }

    func test_handle_shouldNotifyDelegateFailure_whenCreateTransactionFails() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(delegate: delegate, threeDsActionHandler: threeDsHandler)

        component.handle(action: action, presentingViewController: presenter)

        guard let result = delegate.result else {
            XCTFail("expected non-nil result on RyftRequiredActionDelegate")
            return
        }
        switch result {
        case .success:
            XCTFail("expected failure but got success from delegate")
        case .failure:
            XCTAssertTrue(true)
        }
    }

    func test_handle_shouldNotifyDelegateFailure_whenContinuePaymentFails() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        let apiClient = MockRyftApiClient()
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )

        component.handle(action: action, presentingViewController: presenter)

        guard let result = delegate.result else {
            XCTFail("expected non-nil result on RyftRequiredActionDelegate")
            return
        }
        switch result {
        case .success:
            XCTFail("expected failure but got success from delegate")
        case .failure:
            XCTAssertTrue(true)
        }
    }

    func test_handle_shouldNotifyDelegateSuccess_whenContinuePaymentSucceeds() {
        let paymentSession = TestFixtures.paymentSession()
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = paymentSession
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )

        component.handle(action: action, presentingViewController: presenter)

        guard let result = delegate.result else {
            XCTFail("expected non-nil result on RyftRequiredActionDelegate")
            return
        }
        switch result {
        case .success(let updatedSession):
            XCTAssertEqual(updatedSession.id, paymentSession.id)
        case .failure(let error):
            XCTFail("expected success but got error from delegate \(error)")
        }
    }

    func test_handle_shouldCallDoChallenge_whenContinuePaymentReturnsChallengeAction() {
        let challengeAction = TestFixtures.challengeAction()
        let sessionWithChallenge = TestFixtures.paymentSession(challengeAction: challengeAction)
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = sessionWithChallenge
        let component = createComponent(apiClient: apiClient, threeDsActionHandler: threeDsHandler)

        component.handle(action: action, presentingViewController: presenter)

        XCTAssertTrue(threeDsHandler.doChallengeInvoked)
    }

    func test_handle_shouldCallCleanup_afterFlowCompletes() {
        let paymentSession = TestFixtures.paymentSession()
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        threeDsHandler.transactionResult = .success(TestFixtures.threeDsTransactionParams())
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = paymentSession
        let component = createComponent(apiClient: apiClient, threeDsActionHandler: threeDsHandler)

        component.handle(action: action, presentingViewController: presenter)

        XCTAssertTrue(threeDsHandler.cleanupInvoked)
    }

    private func createComponent(
        apiClient: RyftApiClient = MockRyftApiClient(),
        delegate: RyftRequiredActionDelegate? = nil,
        threeDsActionHandler: RyftThreeDsActionHandler,
        accountId: String? = nil
    ) -> RyftRequiredActionComponent {
        let config = RyftRequiredActionComponent.Configuration(
            clientSecret: "secret",
            accountId: accountId
        )
        let component = RyftRequiredActionComponent(
            config: config,
            apiClient: apiClient,
            threeDsActionHandler: threeDsActionHandler
        )
        component.delegate = delegate
        return component
    }
}
