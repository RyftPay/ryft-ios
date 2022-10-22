import XCTest
import RyftCore

@testable import RyftUI

final class RyftRequiredActionComponentTests: XCTestCase {

    func test_handle_shouldCallThreeDsActionHandler_whenGivenIdentifyAction() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        let apiClient = MockRyftApiClient()
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )
        component.handle(action: action)
        XCTAssertTrue(threeDsHandler.handleInvoked)
        XCTAssertEqual(action.identify!, threeDsHandler.action)
        XCTAssertTrue(delegate.inProgress)
    }

    func test_handle_shouldCallApiClientAsExpected_afterHandlingThreeDsIdentifyAction() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        let apiClient = MockRyftApiClient()
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )
        component.handle(action: action)
        guard let request = apiClient.attemptPaymentRequest else {
            XCTFail("attempt-payment request was nil")
            return
        }
        XCTAssertNotNil(request.paymentMethod)
        XCTAssertEqual(
            action.identify!.paymentMethodId,
            request.paymentMethod!.id
        )
    }

    func test_handle_shouldCallApiClientAsExpectedForSubAccount_afterHandlingThreeDsIdentifyAction() {
        let accountId = "ac_3fe8398f-8cdb-43a3-9be2-806c4f84c327"
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        let apiClient = MockRyftApiClient()
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler,
            accountId: accountId
        )
        component.handle(action: action)
        guard let request = apiClient.attemptPaymentRequest else {
            XCTFail("attempt-payment request was nil")
            return
        }
        XCTAssertNotNil(request.paymentMethod)
        XCTAssertEqual(
            action.identify!.paymentMethodId,
            request.paymentMethod!.id
        )
        XCTAssertEqual(accountId, apiClient.accountId)
    }

    func test_handle_shouldCompleteWithResultOfFailedApiCall_afterHandlingThreeDsIdentifyAction() {
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        let apiClient = MockRyftApiClient()
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )
        component.handle(action: action)
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

    func test_handle_shouldCompleteWithResultOfSuccessfulApiCall_afterHandlingThreeDsIdentifyAction() {
        let paymentSession = TestFixtures.paymentSession()
        let action = TestFixtures.identifyAction()
        let threeDsHandler = MockRyftThreeDsActionHandler()
        let apiClient = MockRyftApiClient()
        apiClient.paymentSession = paymentSession
        let delegate = RyftRequiredActionDelegateTester()
        let component = createComponent(
            apiClient: apiClient,
            delegate: delegate,
            threeDsActionHandler: threeDsHandler
        )
        component.handle(action: action)
        guard let result = delegate.result else {
            XCTFail("expected non-nil result on RyftRequiredActionDelegate")
            return
        }
        switch result {
        case .success(let updatedPaymentSession):
            XCTAssertEqual(updatedPaymentSession.id, paymentSession.id)
        case .failure(let error):
            XCTFail("expected success but got error from delegate \(error)")
        }
    }

    private func createComponent(
        apiClient: RyftApiClient,
        delegate: RyftRequiredActionDelegate,
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
